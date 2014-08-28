# encoding: utf-8

module Backup
  module Storage
    class Usb < Base
      class Error < Backup::Error; end

      def initialize(model, storage_id = nil)
        super

        @path ||= '~/backups'
      end

      private

      def transfer!
        FileUtils.mkdir_p(remote_path)

        package.filenames.each do |filename|
          src = File.join(Config.tmp_path, filename)
          dest = File.join(remote_path, filename)
          Logger.info "Storing '#{ dest }'..."

          FileUtils.send(:cp, src, dest)
        end
      end

      # expanded since this is a local path
      def remote_path(pkg = package)
        File.expand_path(super)
      end
      alias :remote_path_for :remote_path
    end
  end
end
