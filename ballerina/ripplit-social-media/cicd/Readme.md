## CI/CD Guide

Continuous Integration (CI) and Continuous Deployment (CD) are essential components of any modern 
software application. For the `ripplit_service`, separate templates for CI and CD workflows using GitHub 
Actions have been included here.

### CI Template

The CI template (`ci.yaml`) is designed to build the application and publish a Docker image to Docker Hub.

### CD Template

The CD template (`cd.yaml`) utilizes Helm charts to generate Kubernetes artifacts and deploy the latest application to an Azure Kubernetes cluster using these artifacts.

As a best practice, the CD pipeline is typically set up in a separate Git repository that contains the 
relevant Helm charts.

In the provided Helm charts, ingress-related configurations have been excluded, as ingress management 
will be handled separately in a production deployment.
