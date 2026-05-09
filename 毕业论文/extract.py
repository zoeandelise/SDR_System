import zipfile
import xml.etree.ElementTree as ET

docx_path = r'e:\study\BISHE\SDR_System\毕业论文\9.毕业论文向俊宇.docx'

with zipfile.ZipFile(docx_path) as docx:
    xml_content = docx.read('word/document.xml')
    tree = ET.XML(xml_content)
    paras = [ ''.join(node.text for node in p.iter('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t') if node.text) for p in tree.iter('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}p') ]
    text = '\n'.join(p for p in paras if p)
    with open(r'e:\study\BISHE\SDR_System\毕业论文\extract.txt', 'w', encoding='utf-8') as f:
        f.write(text)
