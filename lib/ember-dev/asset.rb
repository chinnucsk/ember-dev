require 'pathname'
require_relative 'publish'

module EmberDev
  module Publish
    class Asset
      attr_accessor :file, :current_revision, :current_tag, :stable

      def initialize(filename, options = nil)
        options              ||= {}

        self.file             = Pathname.new(filename)
        self.current_revision = options.fetch(:revision) { EmberDev::Publish.current_revision }
        self.current_tag      = options.fetch(:tag)      { EmberDev::Publish.current_tag }
        self.stable           = options.fetch(:stable)   { false }
      end

      def basename
        file.basename.sub_ext('')
      end

      def unminified_source
        file
      end

      def has_tag
        current_tag.to_s != ''
      end

      def stable
        @stable
      end

      def targets_for(extension)
        targets = []
        prefix  = ''

        if stable
          prefix  = 'stable/'
          targets << "#{prefix}#{basename}#{extension}"
        else
          targets << "#{basename}-latest#{extension}"
          targets << "latest/#{basename}#{extension}"
        end

        targets << "#{prefix}daily/#{Date.today.strftime('%Y%m%d')}/#{basename}#{extension}"
        targets << "#{prefix}shas/#{current_revision}/#{basename}#{extension}"

        targets << "tags/#{current_tag}/#{basename}#{extension}" if has_tag

        targets.compact
      end

      def unminified_targets
        targets_for('.js')
      end

      def minified_source
        file.sub_ext('.min.js')
      end

      def minified_targets
        targets_for('.min.js')
      end

      def production_source
        file.sub_ext('.prod.js')
      end

      def production_targets
        targets_for('.prod.js')
      end

      def files_for_publishing
        { unminified_source => unminified_targets,
          minified_source   => minified_targets,
          production_source => production_targets }
      end
    end
  end
end
