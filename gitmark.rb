require 'net/https'
Net::HTTP.version_1_2

class GitMark
  attr_reader :uri, :content, :res
  GIT_URI = 'https://api.github.com/markdown/raw'

  HEADER = <<-HTML
  <html>
  <head>
   <link href="https://a248.e.akamai.net/assets.github.com/assets/github-4cdfe51085d51343892c756d1d0a1264ec8d8668.css" media="screen" rel="stylesheet" type="text/css" />
  </head>
  HTML

  HTML = <<-HTML
  <body>
    <div id="markdown" style="width:700px;margin:auto;margin-top:50px;padding-bottom:50px">
       <div class="markdown-body">
          <%= BODY %>
        </div>
    </div>
  </body>
  </html>
  HTML

  def initialize
    @uri = GIT_URI
  end

  def read_file(file_path=nil)
    abort "no such file #{file_path}" unless File.exists?(file_path)
    @basename = File.basename(file_path, ".*")
    open(file_path) do |file|
      @content = file.read
    end
    @content.chomp!
    self
  end

  def post
    uri = URI.parse(@uri)

    req = Net::HTTP::Post.new(uri.request_uri)
    req.set_content_type('text/x-markdown')
    req.body = @content

    https = Net::HTTP.new(uri.host, uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE

    @res =  https.start.request(req)
    case @res
    when Net::HTTPSuccess
      self
    else
      abort "Github connection error!"
    end
  end

  def write_content(result=nil)
    open(@basename + ".html", 'w') do |dest|
      body = HTML.sub!(/<%= BODY %>/, result || @res.body)
      dest.write ("#{HEADER}#{body}")
    end
  end
end

