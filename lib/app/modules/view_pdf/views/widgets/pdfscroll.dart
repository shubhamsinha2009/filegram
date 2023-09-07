// import 'package:flutter/material.dart';
// import 'package:pdf_render/pdf_render_widgets.dart';

// import '../../controllers/view_pdf_controller.dart';

// class PdfScroll extends StatelessWidget {
//   const PdfScroll({
//     super.key,
//     required this.controller,
//   });

//   final ViewPdfController controller;

//   @override
//   Widget build(BuildContext context) {
//     return PdfDocumentLoader.openFile(
//       controller.fileOut,
//       documentBuilder: (context, pdfDocument, pageCount) => LayoutBuilder(
//           builder: (context, constraints) => SizedBox(
//                 height: 100,
//                 child: ListView.builder(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: pageCount,
//                     itemBuilder: (context, index) => Container(
//                         height: 50,
//                         margin: const EdgeInsets.all(0),
//                         padding: const EdgeInsets.all(0),
//                         color: Colors.black12,
//                         child: PdfPageView(
//                           pdfDocument: pdfDocument,
//                           pageNumber: index + 1,
//                           pageBuilder: (context, textureBuilder, pageSize) {
//                             //
//                             // This illustrates how to decorate the page image with other widgets
//                             //
//                             return Stack(
//                               alignment: Alignment.bottomCenter,
//                               children: <Widget>[
//                                 // the container adds shadow on each page
//                                 Container(
//                                     margin: const EdgeInsets.all(2),
//                                     padding: const EdgeInsets.all(2),
//                                     decoration: const BoxDecoration(
//                                         color: Colors.white,
//                                         boxShadow: [
//                                           BoxShadow(
//                                               color: Colors.black45,
//                                               blurRadius: 4,
//                                               offset: Offset(2, 2))
//                                         ]),
//                                     // textureBuilder builds the actual page image
//                                     child: textureBuilder()),
//                                 // adding page number on the bottom of rendered page
//                                 Text('${index + 1}',
//                                     style: const TextStyle(
//                                       fontSize: 20,
//                                       fontWeight: FontWeight.bold,
//                                     ))
//                               ],
//                             );
//                           },
//                         ))),
//               )),
//     );
//   }
// }
