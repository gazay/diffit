require 'spec_helper'

require 'ammeter/init'
require 'generators/diffit/init/init_generator'

describe Diffit::InitGenerator, type: :generator do

  destination File.expand_path("../../../tmp", __FILE__)

  before do
    prepare_destination
  end

  it "creates an initializer" do
    expect(generator).to receive :create_initializer
    generator.invoke_all
  end

  describe 'initializer' do

    before do
      run_generator
    end

    subject { file('config/initializers/diffit.rb') }
    it { is_expected.to exist }
    it { is_expected.to contain %r{config\.table_name} }
    it { is_expected.to contain %r{config\.function_name} }

  end
end
