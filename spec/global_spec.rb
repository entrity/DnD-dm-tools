require 'spec_helper'

describe 'r' do
  it 'raises no error' do
    expect { r 'd20 + 4 + 3d6' }.to_not raise_error
  end
end
