CD "C:\Program Files (x86)\Jenkins"
javaw -Dhudson.util.ProcessTree.disable=true  -jar jenkins.war --httpListenAddress=localhost --httpPort=666
exit