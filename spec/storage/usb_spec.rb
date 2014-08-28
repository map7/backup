# encoding: utf-8

require File.expand_path('../../spec_helper.rb', __FILE__)

module Backup
  describe Storage::Usb do
    let(:model) { Model.new(:test_trigger, 'test label') }
    let(:storage) { Storage::Usb.new(model) }
    let(:s) { sequence '' }

    it_behaves_like 'a class that includes Config::Helpers'
    it_behaves_like 'a subclass of Storage::Base'

    describe '#initialize' do

      it 'provides default values' do
        expect( storage.storage_id ).to be_nil
        expect( storage.keep       ).to be_nil
        expect( storage.path       ).to eq '~/backups'
      end

      it 'configures the storage' do
        storage = Storage::Usb.new(model, :my_id) do |usb|
          usb.keep = 2
          usb.path = '/my/path'
        end

        expect( storage.storage_id ).to eq 'my_id'
        expect( storage.keep       ).to be 2
        expect( storage.path       ).to eq '/my/path'
      end

    end # describe '#initialize'

    describe '#transfer!' do
      let(:timestamp) { Time.now.strftime("%Y.%m.%d.%H.%M.%S") }
      let(:remote_path) {
        File.expand_path(File.join('my/path/test_trigger', timestamp))
      }

      before do
        Timecop.freeze
        storage.package.time = timestamp
        storage.package.stubs(:filenames).returns(
          ['test_trigger.tar-aa', 'test_trigger.tar-ab']
        )
        storage.path = 'my/path'
      end

      after { Timecop.return }

      before do
        model.storages << storage
        model.storages << Storage::Usb.new(model)
      end

      it 'copies the package files to their destination' do
        FileUtils.expects(:mkdir_p).in_sequence(s).with(remote_path)

        src = File.join(Config.tmp_path, 'test_trigger.tar-aa')
        dest = File.join(remote_path, 'test_trigger.tar-aa')
        Logger.expects(:info).in_sequence(s).with("Storing '#{ dest }'...")
        FileUtils.expects(:cp).in_sequence(s).with(src, dest)

        src = File.join(Config.tmp_path, 'test_trigger.tar-ab')
        dest = File.join(remote_path, 'test_trigger.tar-ab')
        Logger.expects(:info).in_sequence(s).with("Storing '#{ dest }'...")
        FileUtils.expects(:cp).in_sequence(s).with(src, dest)

        storage.send(:transfer!)
      end

    end # describe '#transfer!'

  end
end
