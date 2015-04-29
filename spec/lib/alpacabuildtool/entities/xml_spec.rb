require 'spec_helper'
require 'alpacabuildtool/entities/xml'

describe AlpacaBuildTool::Xml do
  describe '.to_s' do
    context 'with simple nuspec like structure' do
      subject do
        AlpacaBuildTool::Xml.new '1.0' do
          node 'root' do
            node 'files' do
              node 'file' do
                attribute('src', 'A.txt')
              end
              node 'file' do
                attribute 'src', 'B.txt'
                attribute 'help', 'B file'
              end
            end
            node 'metadata'
          end
        end
      end

      let(:xml_content) do
        "<?xml version=\"1.0\"?>\n" \
        "<root>\n" \
        "\t<files>\n" \
        "\t\t<file src=\"A.txt\"/>\n" \
        "\t\t<file src=\"B.txt\" help=\"B file\"/>\n" \
        "\t</files>\n" \
        "\t<metadata/>\n" \
        '</root>'
      end
      it 'returns well formatted xml' do
        expect(subject.to_s).to eq xml_content
      end
    end
  end
end
