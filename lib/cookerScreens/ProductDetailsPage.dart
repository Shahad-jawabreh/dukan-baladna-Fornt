import 'package:dukan_baladna/cookerScreens/ProductsPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'dart:io';  
import 'package:image_picker/image_picker.dart'; // لاختيار الصور
import 'package:dukan_baladna/globle.dart';
class ProductDetailsPage extends StatefulWidget {
  final String id; // Product ID
  final Function onUpdate; // Callback to refresh the parent page

  ProductDetailsPage({required this.id, required this.onUpdate});


  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final _formKey = GlobalKey<FormState>();

  // Product details
  String name = '';
  int price = 0;
  int discount = 0;
  int stock = 0;
  String description = '';
  String imageUrl = '';
  String status = '';

  bool isLoading = true; // Loader flag
XFile? _imageFile;  // متغير اختياري يمكن أن يكون null

  final picker = ImagePicker(); // لاختيار الصورة من المعرض أو الكاميرا

  @override
  void initState() {
    super.initState();
    fetchProductDetails();
  }

  // Fetch product details from API
  void fetchProductDetails() async {
    final url = Uri.parse('http://10.0.2.2:4000/product/info/${widget.id}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final productData = json.decode(response.body)['product'];

      setState(() {
        name = productData['name'];
        price = productData['price'];
        discount = productData['discount'] ?? 0;
        stock = productData['stock'] ?? 0;
        description = productData['description'] ?? '';
        imageUrl = productData['mainImage']['secure_url'] ?? '';
        status = productData['status'] ?? 'مفعل';
        isLoading = false;
      });
    } else {
      print('Failed to load product details');
    }
  }

  // Update product details on the server
  void updateProduct() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.parse('$domain/product/${widget.id}');
      var request = http.MultipartRequest('PATCH', url)
        ..headers.addAll({
          "Authorization":
              "brear_$token"
        })
        ..fields['name'] = name
        ..fields['price'] = price.toString()
        ..fields['discount'] = discount.toString()
        ..fields['stock'] = stock.toString()
        ..fields['description'] = description
        ..fields['status'] = status;

      // إذا كانت الصورة غير فارغة
      if (_imageFile != null) {
        var imageFile = await http.MultipartFile.fromPath(
          'image', // اسم الحقل في الـ form-data
          _imageFile!.path
        );
        request.files.add(imageFile);
      }

     final response = await request.send();
    final res = await http.Response.fromStream(response);
    final result = json.decode(res.body);
    print(result);
     
    
      if (response.statusCode == 200) {
        await AwesomeDialog(
          context: context,
          title: 'تم التحديث بنجاح',
          dialogType: DialogType.success,
          btnOkText: 'موافق',
          btnOkOnPress: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ProductsPage()));
    
          },
        ).show();
      } else {
        await AwesomeDialog(
          context: context,
          title: ' هذا الصنف موجود بالفعل',
          dialogType: DialogType.error,
          btnOkText: 'موافق',
          btnOkOnPress: () {
            Navigator.pop(context);
          },
        ).show();
      }
    }
  }

  // اختيار صورة من المعرض
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تفاصيل الصنف',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green.shade800,
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.green.shade800,
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade400,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: _imageFile != null
                              ? Image.file(
                                  File(_imageFile!.path),
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  imageUrl,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.broken_image, size: 100),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
                        onPressed: _pickImage,
                        child: Text('تغيير الصورة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildTextFormField(
                      label: 'اسم الصنف',
                      initialValue: name,
                      onSave: (value) => name = value!,
                      validator: (value) =>
                          value!.isEmpty ? 'الرجاء إدخال اسم الصنف' : null,
                    ),
                    _buildTextFormField(
                      label: 'السعر',
                      initialValue: price.toString(),
                      onSave: (value) => price = int.parse(value!),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'الرجاء إدخال السعر' : null,
                    ),
                    _buildTextFormField(
                      label: '% الخصم',
                      initialValue: discount.toString(),
                      onSave: (value) => discount = int.parse(value!),
                      keyboardType: TextInputType.number,
                    ),
                    _buildTextFormField(
                      label: 'المخزون',
                      initialValue: stock.toString(),
                      onSave: (value) => stock = int.parse(value!),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'الرجاء إدخال المخزون' : null,
                    ),
                    _buildTextFormField(
                      label: 'الوصف',
                      initialValue: description,
                      onSave: (value) => description = value!,
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    _buildDropdownField(),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: updateProduct,
                        icon: Icon(Icons.save),
                        label: Text(
                          'حفظ التغييرات',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding:
                              EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextFormField({
    required String label,
    required String initialValue,
    required Function(String?) onSave,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onSaved: onSave,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: status,
      onChanged: (value) {
        setState(() {
          status = value!;
        });
      },
      items: ['مفعل', 'غير مفعل'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'الحالة',
        border: OutlineInputBorder(),
      ),
    );
  }
}
