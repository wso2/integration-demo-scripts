# [Ballerina] Social Media Service

__Authors__: Shafreen  
__Reviewers__: [Yet to fill in]

## Overview

This document is designed to explain the demo script for a social media service built using Ballerina. It is tailored for individuals who may be unfamiliar with Ballerina, making it a great resource to get a hands-on look and feel of the language.

The demo is structured to guide users through both the concepts and practical aspects of Ballerina, with a slide deck introducing core concepts, followed by code examples that reinforce the key points from the slides. The demo covers the "why," "what," and "when" of Ballerina, offering a comprehensive introduction to the language.

Key topics included in the demo:

- Writing services in Ballerina
- Running and testing code
- Deploying services
- Enabling observability features
- Setting up CI/CD pipelines

This demo serves as a complete walkthrough for anyone looking to explore Ballerina's capabilities, from service creation to deployment and monitoring.

## Description

The sample is based on a simple API written for a social media site (like Twitter) that includes users, associated posts, and followers. Below is the high-level component diagram.

<img src="./_resources/diagram.jpg" alt="drawing" width='500'/>

As you can see in the image, this service connects two main endpoints: one is a MySQL endpoint, and the other is an HTTP endpoint. The following is the entity relationship diagram that describes the tables in the database.

<img src="./_resources/er.png" alt="drawing" width='700'/>

Following is the service description.

```ballerina
type SocialMedia service object {
    *http:Service;

    // users resource
    resource function get users() returns User[]|error;
    resource function get users/[int id]() returns User|UserNotFound|error;
    resource function post users(NewUser newUser) returns http:Created|error;
    resource function delete users/[int id]() returns http:NoContent|error;

    // posts resource
    resource function get posts() returns PostWithMeta[]|error;
    resource function get users/[int id]/posts() returns PostMeta[]|UserNotFound|error;
    resource function post users/[int id]/posts(NewPost newPost) returns http:Created|UserNotFound|PostForbidden|error;
};
```

Key featurs that are covered by this scenario are as follows.

- Writing REST APIs with verbs, URLs, data binding and status codes
- Accessing databases
- Configurability
- Debugging Ballerina programs
- HTTP client
- Handling errors
- Writing a simple testcase
- Deploying in Docker and Kubernetes


## Setup Environment

1. Checkout the code base and move to the environment folder
2. Execute `build-docker-images.sh` script to generate the necessary docker images
3. Execute `docker compose up`

Note that the environment includes a simple web application. Below is a sample image.

<img src="./_resources/frontend.png" alt="drawing" width='500'/>

You can use it to show the final outcome. However, during the demo, it might be easier to use the REST Client file in the client folder to try out the service. See the `Try Out` section for more details.

Additionally, it connects to multiple supportive services, such as Integration Control Plane (ICP), Jaeger, Prometheus, and Grafana. The relevant links for each service are as follows:

- Graphana: http://localhost:3000/dashboard
- Prometheus: http://localhost:9090
- Jaeger: http://localhost:16686/
- ICP: https://localhost:9743/login
- Frontend: http://localhost:3001/

## Start the Social Media Service

To start the social media service go to social_media Ballerina project and execute `bal run`.

## Try Out

- To send request open `social-media-request.http` file in client folder using VS Code with `REST Client` extension
- To open the frontend type `http://localhost:3001` in the browser

## CI/CD

The `cicd` folder includes a sample pipeline for github workflows.

## Slides

The following link includes the slides and the recording of the presentation. Please note that the links are private.

- [Slides](https://docs.google.com/presentation/d/1msv4GqDAQtgBVJjAG_CnZb6wSbmhcB15Z68fWuOOYwQ/edit?usp=sharing)
- [Recording](https://drive.google.com/file/d/18kqcwjWSEGxi76KA9TKHbu9FKuP_IsF5/view?usp=sharing)

