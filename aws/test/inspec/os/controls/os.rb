#################################################
# Windows OS Tests
#################################################

# Are we using Windows 10?
control 'os-release' do
  impact 1.0
  desc 'Checks to see that the Windows OS release is correct.'
  describe os.family do
    it { should eq 'windows' }
  end
  describe os.release do
    it { should eq '10.0.16299' }
  end
end

# Do we have a 'hashicorp' user?
control 'training-user' do
  impact 1.0
  desc 'Checks for the training user'
  describe user('hashicorp') do
    it { should exist }
  end
end

# https://hashicorp.github.io/se-terraform-vault-workshop/azure/terraform/#42
control 'terraform-version' do
  impact 1.0
  desc 'Checks to see that Terraform is installed and working.'
  describe powershell('terraform --version') do
    its('stdout') { should match(/0.12.1/) }
  end
end

# Is the correct version of Vault installed?
control 'vault-version' do
  impact 1.0
  desc 'Checks to see that Vault is installed and working.'
  describe powershell('vault --version') do
    its('stdout') { should match(/v1.1.3/) }
  end
end

# Is the correct version of Git installed?
control 'git-version' do
  impact 1.0
  desc 'Checks to see that Git is installed and working.'
  describe powershell('git --version') do
    its('stdout') { should match(/2.22.0.windows.1/) }
  end
end

# Is the correct version of VSC installed?
control 'vsc-version' do
  impact 1.0
  desc 'Checks to see that Visual Studio Code is installed and working.'
  describe powershell('code --version') do
    its('stdout') { should match(/1.35.1/) }
  end
end

# Will the setup script run cleanly?
control 'run-setup-script' do
  impact 1.0
  desc 'Run the setup_aws.ps1 script'
  describe powershell('powershell -ExecutionPolicy ByPass -File C:\Users\Public\Desktop\setup_aws.ps1') do
    its('stdout') { should match(/You may proceed with the workshop./) }
    its('stderr') { should match(//) }
  end
end
