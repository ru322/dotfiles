{ lib, pkgs, ... }:

let
  writerMimeTypes = [
    "application/msword"
    "application/msword-template"
    "application/vnd.ms-word.document.macroEnabled.12"
    "application/vnd.ms-word.template.macroEnabled.12"
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
    "application/vnd.openxmlformats-officedocument.wordprocessingml.template"
    "application/vnd.oasis.opendocument.text"
    "application/vnd.oasis.opendocument.text-flat-xml"
    "application/vnd.oasis.opendocument.text-template"
    "application/vnd.sun.xml.writer"
    "application/vnd.sun.xml.writer.template"
    "application/vnd.apple.pages"
    "application/wps-office.wps"
    "application/wps-office.wpt"
    "application/x-hwp"
    "application/rtf"
  ];
  calcMimeTypes = [
    "application/vnd.ms-excel"
    "application/vnd.ms-excel.sheet.macroEnabled.12"
    "application/vnd.ms-excel.sheet.binary.macroEnabled.12"
    "application/vnd.ms-excel.template.macroEnabled.12"
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    "application/vnd.openxmlformats-officedocument.spreadsheetml.template"
    "application/vnd.oasis.opendocument.spreadsheet"
    "application/vnd.oasis.opendocument.spreadsheet-flat-xml"
    "application/vnd.oasis.opendocument.spreadsheet-template"
    "application/vnd.sun.xml.calc"
    "application/vnd.apple.numbers"
    "application/wps-office.et"
    "application/wps-office.ett"
    "text/csv"
    "text/tab-separated-values"
  ];
  impressMimeTypes = [
    "application/vnd.ms-powerpoint"
    "application/vnd.ms-powerpoint.presentation.macroEnabled.12"
    "application/vnd.ms-powerpoint.slideshow.macroEnabled.12"
    "application/vnd.ms-powerpoint.template.macroEnabled.12"
    "application/vnd.openxmlformats-officedocument.presentationml.presentation"
    "application/vnd.openxmlformats-officedocument.presentationml.slideshow"
    "application/vnd.openxmlformats-officedocument.presentationml.template"
    "application/vnd.oasis.opendocument.presentation"
    "application/vnd.oasis.opendocument.presentation-flat-xml"
    "application/vnd.oasis.opendocument.presentation-template"
    "application/vnd.sun.xml.impress"
    "application/vnd.apple.keynote"
    "application/wps-office.dps"
    "application/wps-office.dpt"
  ];
  drawMimeTypes = [
    "application/vnd.ms-visio.drawing.main+xml"
    "application/vnd.ms-visio.drawing.macroEnabled.main+xml"
    "application/vnd.ms-visio.stencil.main+xml"
    "application/vnd.ms-visio.stencil.macroEnabled.main+xml"
    "application/vnd.ms-visio.template.main+xml"
    "application/vnd.ms-visio.template.macroEnabled.main+xml"
    "application/vnd.oasis.opendocument.graphics"
  ];
in
{
  home.packages = [ pkgs.libreoffice ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      lib.genAttrs writerMimeTypes (_: [ "libreoffice-writer.desktop" ])
      // lib.genAttrs calcMimeTypes (_: [ "libreoffice-calc.desktop" ])
      // lib.genAttrs impressMimeTypes (_: [ "libreoffice-impress.desktop" ])
      // lib.genAttrs drawMimeTypes (_: [ "libreoffice-draw.desktop" ]);
  };
}
