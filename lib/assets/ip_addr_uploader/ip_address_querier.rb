class IpAddressQuerier
  def get_addr
    response = Excon.get(PUBLIC_IP_ADDR_URL)
    response.body.strip
  end

  private
  PUBLIC_IP_ADDR_URL = 'http://ipinfo.io/ip'
end
