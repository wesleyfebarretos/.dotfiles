FROM ubuntu

# Install any necessary packages with root privileges
RUN apt update && \
    apt -y install sudo

# Create the user 'weslyn' and a home directory for the user
RUN useradd -m -p "" weslyn 

RUN echo "weslyn ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Copy the script to the home directory of the new user
COPY install.sh /home/weslyn/install.sh

# Change the permissions of the script to make sure it's executable
RUN chmod +x /home/weslyn/install.sh

# Change the owner of the script to 'weslyn'
RUN chown weslyn:weslyn /home/weslyn/install.sh

# Set the user to 'weslyn'
USER weslyn

# Set the working directory to the home directory of 'weslyn'
WORKDIR /home/weslyn

# Set the entrypoint to execute the script
# ENTRYPOINT ["./install.sh"]

