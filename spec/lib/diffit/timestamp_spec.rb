# encoding: utf-8

describe Diffit::Timestamp, '#new' do
  subject { described_class.new input }

  let(:invalid) { double :invalid }
  let(:output)  { DateTime.new }
  let(:inputs)  { [output, output.to_time, output.to_s, output.to_time.to_i] }

  it 'converts valid arguments to datetime' do
    inputs.each { |input| expect(described_class.new input).to eql(output) }
  end

  it 'complains about wrong argument' do
    expect { described_class.new invalid }.to raise_error do |error|
      expect(error).to be_kind_of ArgumentError
      expect(error.message).to eql "#{invalid.inspect} is not a timestamp!"
    end
  end
end # describe Diffit::Timestamp#new
