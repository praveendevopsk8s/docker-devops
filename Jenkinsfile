pipeline {
    agent any
    
    environment {
        NETLIFY_SITE_ID = '36144c89-7e2f-4fd5-bc2e-9b34b30a22f3'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
    }

    stages {   
        stage('Deploy Staging') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                    args '--user=root'
                }
            }
            steps {
                sh '''
                    # Use a writable directory for npm global installs and cache
                    echo "Small change to trigger the CI/CD Jenkins Pipeline"
                    export HOME=/tmp/jenkins
                    mkdir -p $HOME/.npm-global
                    mkdir -p $HOME/.npm-cache
                    # Set npm to use this directory for global installs and cache
                    npm config set prefix="$HOME/.npm-global"
                    npm config set cache "$HOME/.npm-cache"
                    # Update the PATH to include the new directory
                    export PATH=$HOME/.npm-global/bin:$PATH
                    # Debugging: Print HOME, PATH, and current user
                    echo "HOME: $HOME"
                    echo "PATH: $PATH"
                    echo "Current User: $(whoami)"
                    # Install netlify-cli and node-jq globally
                    npm install -g netlify-cli node-jq
                    # Verify installation and paths
                    npm list -g --depth=0
                    echo "Checking for node-jq installation..."
                    which node-jq || echo "node-jq not found in PATH"
                    ls -al $HOME/.npm-global/bin || echo "No executables found in $HOME/.npm-global/bin"
                    echo "Now shall wait for some time"
                    sleep 10
                    netlify --version
                    node-jq --version || echo "node-jq not available"
                    echo 'Deploying to site: $NETLIFY_SITE_ID'
                    netlify status
                    netlify deploy --dir=build --json > deploy-output.json    
                    node-jq -r '.deploy_url' deploy-output.json
                '''
                // script {
                //     // Attempt to use node-jq from a specific path
                //     def nodeJqPath = sh(script: "which node-jq || echo '$HOME/.npm-global/bin/node-jq'", returnStdout: true).trim()
                //     echo "Using node-jq from path: ${nodeJqPath}"
                //     env.STAGING_URL = sh(script: "${nodeJqPath} -r '.deploy_url' deploy-output.json", returnStdout: true).trim()
                // }
                // echo "Staging URL: ${env.STAGING_URL}"
            }                    
        }
    }
}
