FROM tomcat:11.0-jdk23
RUN rm -rf /usr/local/tomcat/webapps/*
COPY SeilatsatsiSaRona.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
