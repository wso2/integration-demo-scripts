// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.
import ballerina/http;
import ballerina/log;
import ballerina/regex;
import ballerina/sql;
import ballerina/time;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerinax/prometheus as _;
import ballerinax/jaeger as _;
import ballerinax/wso2.controlplane as _;

final mysql:Client ripplitDb = check initDbClient();
final http:Client sentimentEndpoint = check new (sentimentEndpointConfig.endpointUrl);

listener http:Listener ripplitListener = new (9095);

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"]
    }
}
service /ripplit on ripplitListener {

    public function init() returns error? {
        log:printInfo("Ripplit service started");
    }

    // Service-level error interceptors can handle errors occurred during the service execution.
    public function createInterceptors() returns ResponseErrorInterceptor {
        return new ResponseErrorInterceptor();
    }

    # Get all the users
    #
    # + return - The list of users or error message
    resource function get users() returns User[]|error {
        stream<User, sql:Error?> userStream = ripplitDb->query(`SELECT * FROM users`);
        return from User user in userStream
            select user;
    }

    # Get a specific user
    #
    # + id - The user ID of the user to be retrived
    # + return - A specific user or error message
    resource function get users/[int id]() returns User|UserNotFound|error {
        User|error result = ripplitDb->queryRow(`SELECT * FROM users WHERE ID = ${id}`);
        if result is sql:NoRowsError {
            ErrorDetails errorDetails = buildErrorPayload(string `id: ${id}`, string `users/${id}/posts`);
            UserNotFound userNotFound = {
                body: errorDetails
            };
            return userNotFound;
        } else {
            return result;
        }
    }

    # Create a new user
    #
    # + newUser - The user details of the new user
    # + return - The created message or error message
    resource function post users(NewUser newUser) returns http:Created|error {
        _ = check ripplitDb->execute(`
            INSERT INTO users(birth_date, name, mobile_number)
            VALUES (${newUser.birthDate}, ${newUser.name}, ${newUser.mobileNumber});`);
        return http:CREATED;
    }

    # Delete a user
    #
    # + id - The user ID of the user to be deleted
    # + return - The success message or error message
    resource function delete users/[int id]() returns http:NoContent|error {
        _ = check ripplitDb->execute(`
            DELETE FROM users WHERE id = ${id};`);
        return http:NO_CONTENT;
    }

    # Get posts for a given user
    #
    # + id - The user ID for which posts are retrieved
    # + return - A list of posts or error message
    resource function get users/[int id]/posts() returns PostWithMeta[]|UserNotFound|error {
        User|error result = ripplitDb->queryRow(`SELECT * FROM users WHERE id = ${id}`);
        if result is sql:NoRowsError {
            ErrorDetails errorDetails = buildErrorPayload(string `id: ${id}`, string `users/${id}/posts`);
            UserNotFound userNotFound = {
                body: errorDetails
            };
            return userNotFound;
        }
        if result is error {
            return result;
        }

        stream<Post, sql:Error?> postStream = ripplitDb->query(`SELECT id, description, category, created_time_stamp, tags FROM posts WHERE user_id = ${id}`);
        Post[]|error posts = from Post post in postStream
            select post;

        return sortPostsByTime(mapPostToPostWithMeta(check posts, result.name));
    }

    # Get posts from all the users
    #
    # + return - A list of posts or error message
    resource function get posts() returns PostWithMeta[]|error {
        stream<User, sql:Error?> userStream = ripplitDb->query(`SELECT * FROM users`);
        PostWithMeta[] posts = [];
        User[] users = check from User user in userStream
            select user;

        foreach User user in users {
            stream<Post, sql:Error?> postStream = ripplitDb->query(`SELECT id, description, category, created_time_stamp, tags FROM posts WHERE user_id = ${user.id}`);
            Post[]|error userPosts = from Post post in postStream
                select post;
            PostWithMeta[] postsWithMeta = mapPostToPostWithMeta(check userPosts, user.name);
            posts.push(...postsWithMeta);
        }
        return sortPostsByTime(posts);
    }

    # Create a post for a given user
    #
    # + id - The user ID for which the post is created
    # + return - The created message or error message
    resource function post users/[int id]/posts(NewPost newPost) returns http:Created|UserNotFound|PostForbidden|error {
        User|error user = ripplitDb->queryRow(`SELECT * FROM users WHERE id = ${id}`);
        if user is sql:NoRowsError {
            ErrorDetails errorDetails = buildErrorPayload(string `id: ${id}`, string `users/${id}/posts`);
            UserNotFound userNotFound = {
                body: errorDetails
            };
            return userNotFound;
        }
        if user is error {
            return user;
        }

        Sentiment sentiment = check sentimentEndpoint->/api/sentiment.post(
            {text: newPost.description}
        );
        if sentiment.label == "neg" {
            ErrorDetails errorDetails = buildErrorPayload(string `id: ${id}`, string `users/${id}/posts`);
            PostForbidden postForbidden = {
                body: errorDetails
            };
            return postForbidden;
        }

        _ = check ripplitDb->execute(`
            INSERT INTO posts(description, category, created_time_stamp, tags, user_id)
            VALUES (${newPost.description}, ${newPost.category}, CURRENT_TIMESTAMP(), ${newPost.tags}, ${id});`);
        return http:CREATED;
    }
}

function buildErrorPayload(string msg, string path) returns ErrorDetails => {
    message: msg,
    timeStamp: time:utcNow(),
    details: string `uri=${path}`
};

function mapPostToPostWithMeta(Post[] posts, string author) returns PostWithMeta[] => from var postItem in posts
    select {
        id: postItem.id,
        description: postItem.description,
        author,
        meta: {
            tags: regex:split(postItem.tags, ","),
            category: postItem.category,
            createdTimeStamp: postItem.createdTimeStamp
        }
    };

function sortPostsByTime(PostWithMeta[] unsortedPosts) returns PostWithMeta[]|error {
    foreach var item in unsortedPosts {
        item.meta.createdTimeStamp.timeAbbrev = "Z";
    }
    PostWithMeta[] sortedPosts = from var post in unsortedPosts
        order by check time:civilToString(post.meta.createdTimeStamp) descending
        select post;
    return sortedPosts;
}

type Probability record {
    decimal neg;
    decimal neutral;
    decimal pos;
};

type Sentiment record {
    Probability probability;
    string label;
};