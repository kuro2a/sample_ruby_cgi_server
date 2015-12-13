#!/usr/bin/ruby
# -*- coding: utf-8 -*-

$:.unshift(File.dirname(File.expand_path(__FILE__)))

require 'webrick'

BIND_ADDRESS          = '0.0.0.0'
LISTEN_PORT           = 8888
DOCUMENT_ROOT         = 'www'
CGI_ROOT              = 'cgi-bin'
CGI_INTERPRETER_PATH  = '/usr/bin/ruby'
CGI_HTTP_ROOT         = '/cgi-bin'

class SampleServer
  @server = nil
  
  def initialize(bind_addr, port, doc_root, bin_path)
    @server = WEBrick::HTTPServer.new({
                                        :BindAddress    => bind_addr,
                                        :Port           => port,
                                        :DocumentRoot   => doc_root,
                                        :CGIInterpreter => bin_path
                                      })
    Dir.glob("#{CGI_ROOT}/*.{rb,cgi}").each do |cgi_program|
      @server.mount([CGI_HTTP_ROOT,File.basename(cgi_program)].join('/'),
                    WEBrick::HTTPServlet::CGIHandler,
                    [File.dirname(File.expand_path(__FILE__)),cgi_program].join('/'))
    end
    Signal.trap(:INT) do
      @server.shutdown
    end
  end

  def start
    @server.start
  end
end

if $0 == __FILE__
  server = SampleServer.new(BIND_ADDRESS, LISTEN_PORT, DOCUMENT_ROOT, CGI_INTERPRETER_PATH)
  server.start
end
