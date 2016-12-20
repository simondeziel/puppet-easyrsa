require 'spec_helper'

testcases = {
  'default' => {
    params: { pki_name: 'pki1' },
    expect: {
      install_dir: '/opt/easyrsa',
      pkiroot: '/etc/easyrsa',
      dn_mode: 'cn_only',
      key_algo: 'rsa',
      key_size: 2048,
      valid_days: 3650,
      country: 'UK',
      state: 'England',
      city: 'Dewsbury',
      email: 'you@yourcompany.com',
      organization: 'Your Company Limited',
      org_unit: 'your_dept',
    }
  },
  'customized' => {
    params: {
      pki_name: 'pki2',
      dn_mode: 'org',
      key: { algo: 'ec', size: 512, valid_days: 3650 },
      country: 'US',
      state: 'New Jersey',
      city: 'Jersey City',
      email: 'you@yourcompany.com',
      organization: 'Your Company Limited',
      org_unit: 'your_dept',
    },
    expect: {
      install_dir: '/opt/easyrsa',
      pkiroot: '/etc/easyrsa',
      dn_mode: 'org',
      key_algo: 'ec',
      key_size: 512,
      valid_days: 3650,
      country: 'US',
      state: 'New Jersey',
      city: 'Jersey City',
      email: 'you@yourcompany.com',
      organization: 'Your Company Limited',
      org_unit: 'your_dept',
    }
  },
}

describe 'easyrsa::server' do

  testcases.each do |server, values|

    let(:pre_condition) { [
      'contain easyrsa',
      'contain easyrsa::params',
      'easyrsa::pki { "#{values[:params][:pki_name]}": }',
    ] }

    context "testing #{server}" do
      let(:title) { server }
      let(:params) { values[:params] }
      it do
        should contain_exec("build-server-#{title}")
          .with_command("#{values[:expect][:install_dir]}/easyrsa --pki-dir='#{values[:expect][:pkiroot]}/#{values[:params][:pki_name]}' --keysize=#{values[:expect][:key_size]} --batch --use-algo='#{values[:expect][:key_algo]}' --days=#{values[:expect][:valid_days]} --req-cn='#{title}' --dn-mode=#{values[:expect][:dn_mode]} --req-c='#{values[:expect][:country]}' --req-st='#{values[:expect][:state]}' --req-city='#{values[:expect][:city]}' --req-org='#{values[:expect][:organization]}' --req-ou='#{values[:expect][:org_unit]}' --req-email='#{values[:expect][:email]}' build-server-full #{title} nopass")
          .with_cwd("#{values[:expect][:install_dir]}")
          .with_creates(["#{values[:expect][:pkiroot]}/#{values[:params][:pki_name]}/issued/#{title}.crt", "#{values[:expect][:pkiroot]}/#{values[:params][:pki_name]}/private/#{title}.key"])
          .with_provider('shell')
          .with_timeout('0')
          .with_logoutput(true)
      end
    end
  end #testcases.each
end #describe
