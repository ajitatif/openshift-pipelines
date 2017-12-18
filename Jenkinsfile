def CONTAINER_NAME="openshift-pipelines"
def CONTAINER_TAG="latest"
def DOCKER_HUB_USER="hakdogan"
def HTTP_PORT="8080"
def PROJECT=""

node {

    stage('Initialize'){
        def dockerHome = tool 'myDocker'
        def mavenHome  = tool 'myMaven'
        env.PATH = "${dockerHome}/bin:${mavenHome}/bin:${env.PATH}"
    }

    stage('Checkout') {
        checkout scm
    }

    stage('Build'){
        sh "mvn clean install"
    }

    stage("Image Prune"){
        imagePrune(CONTAINER_NAME)
    }

    stage('Image Build'){
        imageBuild(CONTAINER_NAME, CONTAINER_TAG)
    }

    stage('Push to Docker Registry'){
        withCredentials([usernamePassword(credentialsId: 'dockerHubAccount', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
            pushToImage(CONTAINER_NAME, CONTAINER_TAG, USERNAME, PASSWORD)
        }
    }

    stage("Build WAR") {
        sh "mvn clean package -Popenshift"
        stash name:"war", includes:"target/openshift-pipelines.war"
    }

    stage("Build Image") {
        unstash name:"war"
        sh "oc start-build ${CONTAINER_NAME}-docker --from-file=target/openshift-pipelines.war -n ${PROJECT}"
        openshiftVerifyBuild bldCfg: "${CONTAINER_NAME}-docker", namespace: PROJECT, waitTime: '20', waitUnit: 'min'
    }

    stage("Deploy") {
        openshiftDeploy deploymentConfig: CONTAINER_NAME, namespace: PROJECT
    }
}

def imagePrune(containerName){
    try {
        sh "docker image prune -f"
        sh "docker stop $containerName"
    } catch(error){}
}

def imageBuild(containerName, tag){
    sh "docker build -t $containerName:$tag  -t $containerName --pull --no-cache ."
    echo "Image build complete"
}

def pushToImage(containerName, tag, dockerUser, dockerPassword){
    sh "docker login -u $dockerUser -p $dockerPassword"
    sh "docker tag $containerName:$tag $dockerUser/$containerName:$tag"
    sh "docker push $dockerUser/$containerName:$tag"
    echo "Image push complete"
}