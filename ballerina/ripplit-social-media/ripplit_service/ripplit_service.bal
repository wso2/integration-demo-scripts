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
import ballerina/sql;
import ballerina/time;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

configurable string host = ?;
configurable string user = ?;
configurable string password = ?;
configurable string database = ?;
configurable int port = ?;

final mysql:Client ripplitDb = check new(host, user, password, database, port);

service /ripplit on new http:Listener(9095) {

    resource function get users() returns User[]|error {
        stream<User, sql:Error?> userStream = ripplitDb->query(`SELECT * FROM users`);
        return from User user in userStream
            select user;
    }

    resource function post users(NewUser newUser) returns http:Created|error {
        _ = check ripplitDb->execute(`
            INSERT INTO users(birth_date, name, mobile_number)
            VALUES (${newUser.birthDate}, ${newUser.name}, ${newUser.mobileNumber});`);
        return http:CREATED;
    }

    resource function get posts() returns Post[]|error {
        stream<Post, sql:Error?> postStream = ripplitDb->query(`
           SELECT id, description, category, created_time_stamp, tags FROM posts`);
        Post[] posts = check from Post post in postStream select post;
        return posts;
    }

    resource function post users/[int id]/posts(NewPost newPost) returns http:Created|http:NotFound|error {
        User|error user = ripplitDb->queryRow(`SELECT * FROM users WHERE id = ${id}`);
        if user is sql:NoRowsError {
            return http:NOT_FOUND;
        }
        if user is error {
            return user;
        }

        _ = check ripplitDb->execute(`
            INSERT INTO posts(description, category, created_time_stamp, tags, user_id)
            VALUES (${newPost.description}, ${newPost.category}, CURRENT_TIMESTAMP(), ${newPost.tags}, ${id});`);
        return http:CREATED;
    }
}

type User record {|
    int id;
    string name;
    @sql:Column {name: "birth_date"}
    time:Date birthDate;
    @sql:Column {name: "mobile_number"}
    string mobileNumber;
|};

public type NewUser record {|
    string name;
    time:Date birthDate;
    string mobileNumber;
|};

type Post record {|
    int id;
    string description;
    string tags;
    string category;
    @sql:Column {name: "created_time_stamp"}
    time:Civil createdTimeStamp;
|};

public type NewPost record {|
    string description;
    string tags;
    string category;
|};