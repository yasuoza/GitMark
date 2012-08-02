require File.expand_path(File.dirname(__FILE__) + '/../gitmark')

describe GitMark do
    before(:all) do
      @gitmark = GitMark.new()
    end

    describe :new do
      subject { @gitmark.uri }
      it 'should set github fetch url' do
        should eq 'https://api.github.com/markdown/raw'
      end
    end

    describe :read_file do
      context "invalid file path" do
        it 'should raise error' do
          lambda {
            @gitmark.read_file('/foobar/foobar.txt')
          }.should raise_error SystemExit
        end
      end

      context "valid file path" do
        it 'should read file' do
          @gitmark.read_file(File.dirname(__FILE__) + "/test.txt")
          @gitmark.content.should eq "Hello world"
        end
      end
    end

    describe :post do
      before do
        @gitmark.read_file(File.dirname(__FILE__) + "/test.txt")
        @gitmark.post
      end

      subject { @gitmark.res.body }

      it 'should POST github API' do
        should eq '<p>Hello world</p>'
      end
    end

    describe :write_content do
      before do
        @gitmark.read_file(File.dirname(__FILE__) + "/test.txt")
      end

      after do
        begin
          File.unlink('./test.html')
        rescue
        end
      end

      context "set result manually" do
        before do
          @gitmark.write_content('Hello world')
        end
        it 'create file' do
          File.exists?('./test.html').should be true
        end
      end

      context "set result by content" do
        before do
          @gitmark.post()
          @gitmark.write_content()
        end

        it 'create file' do
          File.exists?('./test.html').should be true
        end
      end
    end
end
