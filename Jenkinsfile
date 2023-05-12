node {
	withEnv([
		"TF_CLI_ARGS=-no-color"
	]) {
		withCredentials([
			string(credentialsId: 'AWS_ACCESS_KEY_ID', variable: 'AWS_ACCESS_KEY_ID'),
			string(credentialsId: 'AWS_SECRET_ACCESS_KEY', variable: 'AWS_SECRET_ACCESS_KEY'),
			string(credentialsId: 'INFRACOST_API_KEY', variable: 'INFRACOST_API_KEY'),
			string(credentialsId: 'GH_PAT', variable: 'GH_PAT')
		]) {
			checkout scm
			stage('Plan') {
				sh "terraform init"
				sh "terraform plan -out plan.tfplan"
				sh "terraform show -json plan.tfplan > plan.json"
				stash includes: 'plan.json', name: 'tfplan'
			}
			stage('Infracost Breakdown') {
				unstash name: 'tfplan'
				sh "infracost breakdown --usage-file infracost-usage.yml --path plan.json --format json --out-file infracost.json"
				sh "infracost output --path infracost.json --format html --out-file infracost.html"
				sh "infracost output --path infracost.json --format table"
				stash includes: 'infracost.json', name: 'infracost'
				archiveArtifacts artifacts: 'infracost.json, infracost.html, infracost-usage.yml', fingerprint: true
			}
			if (env.CHANGE_ID) {
				stage('Infracost PR Comment') {
					unstash name: 'infracost'
					sh 'infracost comment github --path=infracost.json --repo=doublej472/terraform-cost-test --pull-request=${CHANGE_ID} --github-token=${GH_PAT} --behavior=update'
				}
			}
		}
	}
}
