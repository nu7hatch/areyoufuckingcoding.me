# -*- ruby -*- 
require 'bundler/setup'

class Rack::ExtStatic < Rack::Static
  def call(env)
    resp = super(env)
    if resp[0] == 404
      path_info = env['PATH_INFO']
      env['PATH_INFO'] += @index if path_info =~ /\/$/
      resp = super(env)
    end
    resp
  end
end

use Rack::ExtStatic, {
  :root  => 'output',
  :index => 'index.html',
  :urls  => [""],
}

error_404 = 'output/404/index.html'

run lambda {
  [404, {
    "Content-Type"   => "text/html",
    "Content-Length" => File.size(error_404).to_s,
    "Last-Modified"  => File.mtime(error_404).httpdate,
    }, File.read(error_404)
  ]
}