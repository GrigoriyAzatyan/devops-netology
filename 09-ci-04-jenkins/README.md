# Декларативный Pipeline

```
pipeline {
    agent {
      label 'jenkins-agent-01'
    }
    stages {
        stage('Git') {
             steps {
                 git branch: 'Molecule', changelog: false, poll: false, url: 'https://github.com/GrigoriyAzatyan/kibana-role.git'
             }
        }
        stage('Install requirements') {
             steps {
                 sh 'pip3 install -r /opt/jenkins_agent/workspace/Declarative/test-requirements.txt'
                 sh 'ansible-galaxy install -p . git+https://github.com/GrigoriyAzatyan/kibana-role.git --force'
             }
        }
        stage('Start molecule') {
             steps {
                  sh 'molecule test'
             }
        }
    }
}
```


# Скриптовый Pipeline

```
node("jenkins-agent-01"){
    stage("Git checkout"){
        git credentialsId: 'github', url: 'https://github.com/GrigoriyAzatyan/ELK.git'
    }
    stage("Sample define secret_check"){
        secret_check=true
        prod_run = input(message: 'Is job running for production?', parameters: [booleanParam(defaultValue: false, name: 'prod_run')])
    }
    stage("Run playbook"){
        if (prod_run){
              sh 'ansible-playbook -i inventory/prod.yml site.yml'
                }
	else{
              sh 'ansible-playbook -i inventory/prod.yml site.yml --check --diff'
                }
            }
    }
```
