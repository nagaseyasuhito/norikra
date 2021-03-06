require_relative './spec_helper'

require 'norikra/stats'
require 'norikra/server'

require 'tmpdir'

describe Norikra::Stats do
  describe '#to_hash' do
    it 'returns internal stats as hash with symbolized keys' do
      args = {
        targets: [],
        queries: [],
      }
      s = Norikra::Stats.new(args)
      expect(s.to_hash).to eql(args)
    end
  end

  describe '.load' do
    it 'can restore stats data from #dump -ed json' do
      Dir.mktmpdir do |dir|
        File.open("#{dir}/stats.json", 'w') do |file|
          args = {
            targets: [
              { name: 'test1', fields: { id: { name: 'id', type: 'int', optional: false}, data: { name: 'data', type: 'string', optional: true } } },
            ],
            queries: [
              { name: 'testq2', expression: 'select count(*) from test1.win:time(5 sec)' },
              { name: 'testq1', expression: 'select count(*) from test1.win:time(10 sec)' },
            ],
          }
          s1 = Norikra::Stats.new(args)
          expect(s1.to_hash).to eql(args)

          s1.dump(file.path, nil)

          s2 = Norikra::Stats.load(file.path)
          expect(s2.to_hash).to eql(s1.to_hash)
          expect(s2.to_hash).to eql(args)

          s1.dump(file.path, "#{file.path}.secondary")

          s3 = Norikra::Stats.load("#{file.path}.secondary")
          expect(s3.to_hash).to eql(s1.to_hash)
        end
      end
    end
  end
end
