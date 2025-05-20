import jenkins.model.*
import hudson.slaves.*

def instance = Jenkins.getInstance()
def agent = new DumbSlave(
    "docker-agent", // Имя агента
    "/home/jenkins", // Рабочая директория
    new JNLPLauncher() // Тип подключения (JNLP)
)
instance.addNode(agent)
instance.save()