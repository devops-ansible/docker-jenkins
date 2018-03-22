node {

    def built_image

    def baseimage = 'jenkins/jenkins:lts'

    def image = 'devopsansiblede/jenkins'
    def version = 'lts'

    def old_layers
    def new_layers

    stage('Fetch existing docker image') {
        /* Pulls current live image and determines layer ids of that image */
        try {
            def old_image = docker.image( image + ':' + version ).pull()
            def json = sh ( returnStdout: true, script: 'docker inspect ' + image + ':' + version )
            def data = readJSON text: json
            old_layers = data[0]['RootFS']['Layers']
        } catch (exc) {
            old_layers = readJSON text: '[]'
        }
    }

    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace */
        checkout scm
    }

    stage('Build image') {
        /* This builds the actual image; synonymous to
         * docker build on the command line */
        docker.image( baseimage ).pull()
        built_image = docker.build(image + ':' + version)
    }

    stage('Check Image-Layers') {
        def json = sh ( returnStdout: true, script: 'docker inspect ' + image + ':' + version )
        def data = readJSON text: json
        new_layers = data[0]['RootFS']['Layers']
    }

    if ( old_layers != new_layers ) {
        stage('Push image') {
            /* Finally, we'll push the image with two tags:
             * First, the incremental build number from Jenkins
             * Second, the 'latest' tag.
             * Pushing multiple tags is cheap, as all the layers are reused. */

            withCredentials([usernamePassword( credentialsId: 'technicaluser', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {

                docker.withRegistry('', 'technicaluser') {
                    sh "docker login -u ${USERNAME} -p ${PASSWORD}"
                    built_image.push()
                }
            }
        }
    }
}
