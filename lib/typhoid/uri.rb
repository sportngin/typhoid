require 'uri'
module Typhoid
  class Uri
    private
    attr_writer :base
    attr_writer :paths

    public
    attr_reader :base
    attr_reader :paths

    def initialize(*paths)
      self.base = URI.parse paths.shift.to_s
      self.paths = sanitize(paths)
      raise "Invalid Base on #uri_join: #{base}" unless base.scheme || base.host
    end

    def join(*more_paths)
      full_path = (paths + sanitize(more_paths)).join "/"
      base.clone.merge(full_path).to_s
    end

    def to_s
      join
    end

    def sanitize(*need_sanitizing)
      need_sanitizing.
        flatten.
        compact.
        map { |p| p.to_s.split("/").compact.delete_if(&:empty?) }.
        flatten
    end
    private :sanitize
  end
end
