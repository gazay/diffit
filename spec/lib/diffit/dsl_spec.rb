require 'spec_helper'

describe Diffit::DSL do

  before :all do
    @model = Class.new { extend Diffit::DSL }
  end

  subject { @model }

  it { is_expected.to respond_to :diffit }
  it { is_expected.to_not include Diffit::Trackable }
  it { is_expected.to_not be_a Diffit::Trackable }

  describe '.diffit' do

    before do
      @model.diffit
    end

    it { is_expected.to include Diffit::Trackable }
    it { is_expected.to be_a Diffit::Trackable }

  end
end
