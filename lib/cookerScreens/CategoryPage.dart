import 'package:dukan_baladna/cookerScreens/DashboardPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:dukan_baladna/globle.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http_parser/http_parser.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _productPriceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
 final TextEditingController _stockController = TextEditingController();
    final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

List<Map<String, dynamic>> addons = [];
  String _category = "غير محدد"; // Default category
  bool _isLoadingCategory = false; // Loading state for category detection
  File? _selectedImage; // To hold the selected image
 bool _isImmediateDelivery = false; // Checkbox state
    bool isAddonSelected = false;
  String? _deliveryStatus ; // Default delivery status
  // Categories and Keywords
  final Map<String, List<String>> categoriesKeywords = {
    "مخبوزات": ["خبز", "كعك", "فطائر", "مناقيش", "بسكويت"],
    "مقبلات": ["حمص", "بابا غنوج", "مقالي", "متبل", "فلافل"],
    "مخللات": ["مخلل", "مخلل خيار", "زيتون", "مخلل جزر"],
    "عصائر": ["عصير", "ليمون", "برتقال", "تفاح", "كيوي", "عصير فواكه"],
    "أجبان وألبان": ["لبنة", "جبنة", "زبادي", "حليب", "قشطة"],
    "سلطات": ["سلطة", "تبولة", "فتوش", "سلطة جرجير", "سلطة خضار"],
    "أعشاب وورقيات": ["نعناع", "ريحان", "مردقوش", "زعتر", "كزبرة", "بقدونس"],
    "الأطباق الرئيسية": ["منسف", "اوزة", "يلنجي", "كبسة", "مقلوبة", "محشي", "كفتة", "دجاج", "شاورما"],
    "حلويات": ["كعكة", "كيك", "كيكه", "بسبوسة", "بقلاوة", "كنافة", "قطايف", "معمول"],
  };

  // Function to detect category based on product name and description
  String detectCategory(String productName, String description) {
    String text = (productName + " " + description).toLowerCase();
    for (var category in categoriesKeywords.keys) {
      for (var keyword in categoriesKeywords[category]!) {
        if (text.contains(keyword.toLowerCase())) {
          return category;
        }
      }
    }
    return "غير محدد";
  }

  // Function to detect category using AI API
  Future<void> _detectCategoryAI(String productName, String description) async {
    setState(() {
      _isLoadingCategory = true;
    });

    try {
      String detectedCategory = detectCategory(productName, description);
      setState(() {
        _category = detectedCategory;
      });
    } catch (e) {
      setState(() {
        _category = "خطأ في الاتصال بالخادم";
      });
    } finally {
      setState(() {
        _isLoadingCategory = false;
      });
    }
  }


  File? _image;
  final ImagePicker _picker = ImagePicker();

Future<void> _pickImage() async {
  final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    setState(() {
      _image = File(pickedFile.path);
    });
    print("Image selected: ${_image!.path}"); // Added print statement
  } else {
    print("No image selected.");
  }
}

Future<void> addProduct(
    String name,
    String category,
    String description,
    int? price,
    int? stock,
    String? extras,
    String? _deliveryStatus,
    File? _image) async {

  var request = http.MultipartRequest(
    'POST',
    Uri.parse("$domain/product"),
  );

  request.headers.addAll({
    "Authorization": "brear_$token",
  });

  
  request.fields['name'] = name;
  request.fields['description'] = description;
  request.fields['detectedCategory'] = category;
  request.fields['price'] = price.toString();
  request.fields['createdBy'] = userId;
  request.fields['salerName'] = userName;
  request.fields['deliveryStatus'] = _deliveryStatus ?? "فوري"; // Default delivery status

  // Convert stock to string if it's not null
  if (stock != null) request.fields['stock'] = stock.toString();

  // Send the addons list as JSON
  if (addons.isNotEmpty) {
    request.fields['addOns'] = jsonEncode(addons); // Send as array of objects
  }

  // Handle the image upload if a file is selected
  if (_image != null) {
    var imageFile = await http.MultipartFile.fromPath(
      'mainImage', _image.path, contentType: MediaType('image', 'jpeg') // You can adjust the contentType as needed
    );
    request.files.add(imageFile);
  }

  try {
    final response = await request.send();
    final res = await http.Response.fromStream(response);
    final result = json.decode(res.body);
    print(result);

    if (response.statusCode == 200) {
      if (result['message'] == 'Product added successfully') {
        setState(() {
          _productNameController.clear();
          _productPriceController.clear();
          _descriptionController.clear();
          _category = "غير محدد";
        });
        AwesomeDialog(
          context: context,
          title: 'تمت الاضافة بنجاح',
          dialogType: DialogType.success,
          btnOkText: 'موافق',
          btnOkOnPress: () {
            Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardPage()), // الوجهة الجديدة
      );
          },
        ).show();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add product')));
    }
  } catch (e) {
    print(e);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred')));
  }
}



   void addAddon() {
  String name = _nameController.text;
  double price = double.tryParse(_priceController.text) ?? 0.0;
  Map<String, dynamic> addon = {
    'name': name,
    'price': price,
  };
  setState(() {
    addons.add(addon);  // إضافة الإضافة إلى القائمة
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("إضافة منتج جديد"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Name
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(
                  labelText: "اسم المنتج",
                  hintText: "أدخل اسم المنتج",
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _detectCategoryAI(value, _descriptionController.text);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "يرجى إدخال اسم المنتج";
                  }
                  return null;
                },
              ),
              SizedBox(height: 8.0),
              Row(
                children: [
                  Text(
                    "الفئة: ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: _category,
                    onChanged: (newValue) {
                      setState(() {
                        _category = newValue!;
                      });
                    },
                    items: [
                      ...categoriesKeywords.keys,
                      "غير محدد"
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  _isLoadingCategory
                      ? CircularProgressIndicator()
                      : SizedBox.shrink(),
                ],
              ),
              SizedBox(height: 16.0),
              // Price
              TextFormField(
                controller: _productPriceController,
                decoration: InputDecoration(
                  labelText: "سعر المنتج",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0), 

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "المكونات",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _detectCategoryAI(_productNameController.text, value);
                  }
                },
              ),
  
             SizedBox(height: 16.0),

              // Immediate Delivery Checkbox
               // Delivery Status Dropdown
              DropdownButtonFormField<String>(
                value: _deliveryStatus,
                decoration: InputDecoration(
                  labelText: "حالة التسليم",
                  border: OutlineInputBorder(),
                ),
                items: ["فوري", "حسب الطلب"].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _deliveryStatus = value!;
                  });
                },
              ),
              if (_deliveryStatus == "فوري")
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextFormField(
                    controller: _stockController,
                    decoration: InputDecoration(
                      labelText: "كمية المخزون",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "يرجى إدخال كمية المخزون";
                      }
                      return null;
                    },
                  ),
                ),
              SizedBox(height: 16.0),
// Extras
              CheckboxListTile(
                title: Text("إضافة إضافات"),
                value: isAddonSelected,
                onChanged: (bool? value) {
                  setState(() {
                    isAddonSelected = value!;
                  });
                },
              ),
              if (isAddonSelected) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "اسم الإضافة",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: "سعر الإضافة",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: addAddon,
                  child: Text("إضافة الإضافة"),
                ),
              ],
              SizedBox(height: 16.0),
              Text("الإضافات:"),
              ListView.builder(
              shrinkWrap: true,
              itemCount: addons.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("${addons[index]['name']} - ${addons[index]['price']}"),
                );
              },
            ),

              SizedBox(height: 16.0),
              // Detected Category
            
              Row(
                children: [
                  _image != null
                      ? Image.file(
                          _image!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Container(),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: Text("اختيار صورة"),
                  ),
                ],
              ),
             SizedBox(height: 16.0),

              // Add Product Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    String productName = _productNameController.text;
                    String productCategory = _category;
                    String productDescription = _descriptionController.text;
                    int? productPrice = int.tryParse(_productPriceController.text);
                    addProduct(productName, productCategory, productDescription, productPrice,int.tryParse(_stockController.text)  ,
                      addons.isNotEmpty ? addons.toString() : "", // Send addons list as string or handle it accordingly
                        _deliveryStatus ,_image);
                  }
                },
                child: Text("إضافة المنتج"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
