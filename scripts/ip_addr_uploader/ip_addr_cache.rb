class IpAddrCache
  def initialize(cache_dir)
    @cache_file = File.join(cache_dir, CACHE_FILE)
  end

  def get
    @cached_ip_addr ||= get_cached_ip_addr
  end

  def set(ip_addr)
    write_ip_addr(ip_addr)
    @cached_ip_addr = ip_addr
  end

  def clear
    File.delete(@cache_file) if File.exist?(@cache_file)
  end

  private
  CACHE_FILE = 'public_ip_addr_' + XXhash.xxh64('public_ip_addr_').to_s

  def get_cached_ip_addr
    File.exist?(@cache_file) ? File.read(@cache_file).strip : nil
  end

  def write_ip_addr(ip_addr)
    File.open(@cache_file, 'w') { |file|
      file.write(ip_addr.strip)
    }
  end
end