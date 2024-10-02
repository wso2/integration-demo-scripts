# Use the official Ballerina Docker image as the base image
FROM ballerina/ballerina:2201.9.3

# Set the user to root
USER root

# Set the working directory inside the container
WORKDIR /home/ballerina

# Copy all files from the current directory to the working directory in the container
COPY . .

# Compile the Ballerina project
RUN bal build

# Expose the port number on which the Ballerina service will run inside the container
EXPOSE 9098

# Run the compiled Ballerina program (replace 'your_project_name' with the actual project name if necessary)
CMD ["bal", "run", "target/bin/sentimentapi.jar"]
