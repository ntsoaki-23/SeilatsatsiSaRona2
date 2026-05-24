FROM tomcat:10.1-jdk21
RUN rm -rf /usr/local/tomcat/webapps/*
RUN mkdir -p /usr/local/tomcat/webapps/ROOT
RUN echo '<html><body><h1>Seilatsatsi FIS</h1><p>Deployment Successful!</p><p>Your Financial Information System is running.</p></body></html>' > /usr/local/tomcat/webapps/ROOT/index.jsp
EXPOSE 8080
CMD ["catalina.sh", "run"]
