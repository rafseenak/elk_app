String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter your name';
  } else if (value.length < 3) {
    return 'Name too short';
  } else {
    return null;
  }
}

String? validateDescription(String? value) {
  if (value == null || value.isEmpty) {
    return 'Please enter description';
  } else if (value.length < 3) {
    return 'Description atleast 3 character long';
  } else {
    return null;
  }
}

String? validateAdTitle(String? value) {
  if (value == null || value.isEmpty) {
    return 'Title cannot be empty';
  } else if (value.length < 3) {
    return 'Title atleast 3 character long';
  } else {
    return null;
  }
}

String? validateAdDescription(String? value) {
  if (value == null || value.isEmpty) {
    return 'Description cannot be empty';
  } else if (value.length < 3) {
    return 'Description atleast 3 character long';
  } else {
    return null;
  }
}

String? validateAdprice(String? value) {
  if (value == null || value.isEmpty) {
    return 'Price cannot be empty';
  } else {
    return null;
  }
}
