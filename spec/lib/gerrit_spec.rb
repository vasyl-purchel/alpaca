require_relative '../../lib/alpaca/gerrit'

describe Alpaca::Gerrit do
  before :each do
    allow(subject).to receive(:puts)
  end
  describe '#new' do
    subject { Alpaca::Gerrit.new 'gerrit.alpaca.com', '80', 'id_rsa', 'vasyl' }
    it 'returns Gerrit object' do
      expect(subject).to be_an_instance_of Alpaca::Gerrit
    end

    it 'returns object with host stored' do
      expect(subject.instance_variable_get :@host).to eq 'gerrit.alpaca.com'
    end

    it 'returns object with port stored' do
      expect(subject.instance_variable_get :@port).to eq '80'
    end

    it 'returns object with key stored' do
      expect(subject.instance_variable_get :@key).to eq 'id_rsa'
    end

    it 'returns object with user stored' do
      expect(subject.instance_variable_get :@user).to eq 'vasyl'
    end
  end

  describe '#review' do
    subject { Alpaca::Gerrit.new 'gerrit.alpaca.com', '80', 'id_rsa', 'vasyl' }
    let(:param) do
      result = %w(ssh -i id_rsa vasyl@gerrit.alpaca.com -p 80 gerrit)
      result += %w(review --label tests=-1 10325)
      result.join(' ')
    end

    it 'execute ssh command to update label in review' do
      expect(subject).to receive(:`).with(param)
      subject.review 'tests', '-1', '10325'
    end
  end

  describe '#create_project' do
    subject { Alpaca::Gerrit.new 'gerrit.alpaca.com', '80', 'id_rsa', 'vasyl' }
    let(:param) do
      result = %w(ssh -i id_rsa vasyl@gerrit.alpaca.com -p 80 gerrit)
      result += %w(create-project --name alpaca --parent alpaca_acls)
      result.join(' ')
    end

    context 'When description is not passed' do
      it 'execute ssh command to update label in review' do
        expect(subject).to receive(:`).with(param)
        subject.create_project 'alpaca', 'alpaca_acls'
      end
    end

    context 'When description is passed' do
      it 'execute ssh command to update label in review' do
        descr = ' --description "cool tool"'
        expect(subject).to receive(:`).with(param + descr)
        subject.create_project 'alpaca', 'alpaca_acls', 'cool tool'
      end
    end
  end
end
