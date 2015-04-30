require 'spec_helper'
describe 'sep' do

  context 'with defaults for all parameters' do
    it { should contain_class('sep') }
  end
end
