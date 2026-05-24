FROM tomcat:10.1-jdk21

# Remove default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy your WAR file as ROOT (so it runs at root URL)
COPY SeilatsatsiSaRona.war /usr/local/tomcat/webapps/ROOT.war

# Expose port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
