require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe GoDep do
    let(:options) { {} }
    subject { GoDep.new(options.merge(project_path: Pathname('/fake/path'))) }


    it_behaves_like 'a PackageManager'

    describe '#current_packages' do
      let(:content) do
        '{
          "ImportPath": "github.com/pivotal/foo",
          "GoVersion": "go1.4.2",
          "Deps": [
            {
              "ImportPath": "github.com/pivotal/foo",
              "Rev": "61164e49940b423ba1f12ddbdf01632ac793e5e9"
            },
            {
              "ImportPath": "github.com/pivotal/bar",
              "Rev": "3245708abcdef234589450649872346783298736"
            },
            {
              "ImportPath": "code.google.com/foo/bar",
              "Rev": "3245708abcdef234589450649872346783298735"
            }
          ]
        }'
      end

      before do
        FakeFS do
          FileUtils.mkdir_p '/fake/path/Godeps'
          File.write('/fake/path/Godeps/Godeps.json', content)
        end

        @orig_gopath = ENV['GOPATH']
        ENV['GOPATH'] = '/fake/go/path'
      end

      after do
        ENV['GOPATH'] = @orig_gopath
      end

      it 'sets the homepage for packages' do
        FakeFS do
          packages = subject.current_packages

          expect(packages[0].homepage).to eq("github.com/pivotal/foo")
          expect(packages[1].homepage).to eq("github.com/pivotal/bar")
          expect(packages[2].homepage).to eq("code.google.com/foo/bar")
        end
      end

      context 'when dependencies are vendored' do
        before do
          FakeFS do
          allow(FileTest).to receive(:directory?).with('/fake/path/Godeps/_workspace').and_return(true)
          end
        end

        it 'should return an array of packages' do
          FakeFS do
            packages = subject.current_packages
            expect(packages.map(&:name)).to include('github.com/pivotal/foo', 'github.com/pivotal/bar')
            expect(packages.map(&:version)).to include('61164e4', '3245708')
          end
        end

        it 'should set the install_path to the vendored directory' do
          FakeFS do
            packages = subject.current_packages
            expect(packages[0].install_path).to eq('/fake/path/Godeps/_workspace/src/github.com/pivotal/foo')
            expect(packages[1].install_path).to eq('/fake/path/Godeps/_workspace/src/github.com/pivotal/bar')
          end
        end

        context 'when requesting the full version' do
          let(:options) { { go_full_version:true } }
          it 'list the dependencies with full version' do
            FakeFS do
              expect(subject.current_packages.map(&:version)).to eq [
                                                                        "61164e49940b423ba1f12ddbdf01632ac793e5e9",
                                                                        "3245708abcdef234589450649872346783298736",
                                                                        "3245708abcdef234589450649872346783298735"]
            end
          end
        end
      end

      context 'when there are duplicate dependencies' do
        let(:content) do
          '{
               "ImportPath": "github.com/foo/bar",
               "GoVersion": "go1.3",
               "Deps": [
                {
                    "ImportPath": "github.com/foo/baz/sub1",
                    "Rev": "28838aae6e8158e3695cf90e2f0ed2498b68ee1d"
                },
                {
                    "ImportPath": "github.com/foo/baz/sub2",
                    "Rev": "28838aae6e8158e3695cf90e2f0ed2498b68ee1d"
                },
                {
                    "ImportPath": "github.com/foo/baz/sub3",
                    "Rev": "28838aae6e8158e3695cf90e2f0ed2498b68ee1d"
                }
            ]
          }'
        end

        before do
          FakeFS do
            File.write('/fake/path/Godeps/Godeps.json', content)
          end
        end

        it 'should return one dependency only' do
          FakeFS do
            packages = subject.current_packages
            expect(packages.map(&:name)).to eq(['github.com/foo/baz'])
            expect(packages.map(&:version)).to eq(['28838aa'])
          end
        end
      end

      context 'when dependencies are not vendored' do
        before do
          @orig_gopath = ENV['GOPATH']
          ENV['GOPATH'] = '/fake/go/path'
        end

        after do
          ENV['GOPATH'] = @orig_gopath
        end

        it 'should return an array of packages' do
          FakeFS do
            packages = subject.current_packages
            expect(packages.map(&:name)).to include('github.com/pivotal/foo', 'github.com/pivotal/bar')
            expect(packages.map(&:version)).to include('61164e4', '3245708')
          end
        end

        it 'should set the install_path to the GOPATH' do
          FakeFS do
            packages = subject.current_packages
            expect(packages[0].install_path).to eq('/fake/go/path/src/github.com/pivotal/foo')
            expect(packages[1].install_path).to eq('/fake/go/path/src/github.com/pivotal/bar')
          end
        end
      end
    end
  end
end
