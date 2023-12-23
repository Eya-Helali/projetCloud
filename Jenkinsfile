pipeline {
    agent any

    environment {
       
        // These variables are for terraform to connect to Azure account
        ARM_SUBSCRIPTION_ID = "0c464c51-6d08-41fe-9971-8eda56d5e04a"
        ARM_CLIENT_ID ="9ebf1ce4-707a-4b8f-9a60-350fa1640ad1"
        ARM_CLIENT_SECRET =  "5iH8Q~cwzi2K6z2ZM6_Okt69HfAUqNAE4.Noldn."
        ARM_TENANT_ID = "dbd6664d-4eb9-46eb-99d8-5c43ba153c61"

    }

    stages {
        stage('Checkout') {
            steps {
                // Check out your source code from your version control system, e.g., Git.
                sh 'rm -rf projetCloud'
                sh 'git clone https://github.com/Eya-Helali/projetCloud.git'
            }
        }
                   

        stage('Provision AKS cluster with TF') {
            steps {
                script {

                    sh '''
                       
                       cd terraform/
    
                       terraform fmt && terraform init
    
                       terraform plan && terraform apply --auto-approve 
    
                       terraform output kube_config > kubeconfig && cat kubeconfig 

                       sed -i '1d;$d' kubeconfig && cat kubeconfig
    
                       cd ../
                    '''

                }
            }
        }

        stage('Deploy on AKS') {
            steps {

                sh '''
                    export KUBECONFIG=/var/jenkins_home/workspace/projetCloud/terraform/kubeconfig
                    cd kubernetes
                    kubectl apply -f .

                '''
            }
        }   

        stage(' Nginx-Ingress') {
            steps {
                script {
                    try {
                        sh '''

                        export KUBECONFIG=/var/jenkins_home/workspace/projet-devops/terraform/kubeconfig

                        helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
                        helm repo update
                        helm install app-ingress ingress-nginx/ingress-nginx --namespace ingress --create-namespace --set controller.replicaCount=2 --set controller.nodeSelector."kubernetes\\.io/os"=linux --set defaultBackend.nodeSelector."kubernetes\\.io/os"=linux



                    '''
                    } catch (Exception e) {
                        echo "the helm packages that you are trying to install are already installed with the same name"
                    }
                }
            }
        }


        stage('Monitoring Prometheus & Grafana') {
            steps {
                script {
                    try {

                    sh '''

                        export KUBECONFIG=/var/jenkins_home/workspace/projet-devops/terraform/kubeconfig
                        kubectl create ns monitoring 
                        helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
                        helm repo update
                        helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring
                        kubectl get all,secret,configMap --namespace monitoring           

                    '''


            
                    } catch (Exception e) {
                        echo "the prometheus operator monitoring stack is already installed with the same name "
                    }
                }
            }
        }  
                

    }
    post {
        success {
            echo ' Pipeline completed successfully! :)) '
        }
    }

}
