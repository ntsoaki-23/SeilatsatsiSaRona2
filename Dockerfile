# Use Eclipse Temurin JDK 23 as base
FROM eclipse-temurin:23-jdk

# Set environment variables
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
ENV TOMCAT_MAJOR 10
ENV TOMCAT_VERSION 10.1.28

# Download and install Tomcat
RUN apt-get update && \
    apt-get install -y wget && \
    wget https://dlcdn.apache.org/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar -xzf apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    mv apache-tomcat-${TOMCAT_VERSION} $CATALINA_HOME && \
    rm apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    apt-get clean

# Remove default webapps
RUN rm -rf $CATALINA_HOME/webapps/*

# Copy your WAR file
COPY SeilatsatsiSaRona.war $CATALINA_HOME/webapps/ROOT.war

# Expose port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
