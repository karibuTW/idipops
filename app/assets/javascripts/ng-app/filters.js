angular.module('uneo.filters', [])
  .filter('htmlToPlaintext', function() {
    return function(text) {
      return String(text).replace(/<[^>]+>/gm, '');
    }
  })
  
  .filter('t', function() {
    return function(text, params) {
      return I18n.t(String(text), params);
    }
  })

  .filter('numberByThousand', function() {
    return function(inputNumber) {
      var formattedNumber = inputNumber;
      if (inputNumber >= 10000) {
        formattedNumber = Math.floor(inputNumber / 1000) + 'k';
      } else if (inputNumber >= 1000) {
        remainder = Math.floor((inputNumber % 1000) / 100)
        if (remainder > 0) {
          formattedNumber = Math.floor(inputNumber / 1000) + "." + remainder + "k";
        } else {
          formattedNumber = Math.floor(inputNumber / 1000) + "k";
        }
      }
      return formattedNumber;
    }
  })

  .filter('capitalize', function() {
    return function(input) {
      return input.charAt(0).toUpperCase() + input.substr(1).toLowerCase();
    }
  })

  .filter('formatPhoneNumber', function() {
    return function(inputNumber) {
      var formattedNumber = "";
      if (inputNumber) {
        for (var i=0; i<inputNumber.length; i++) {
          formattedNumber = formattedNumber + inputNumber[i];
          if (i % 2 == 1 && i != inputNumber.length-1) {
            formattedNumber = formattedNumber + " ";
          }
        }
      }
      return formattedNumber;
    }
  })
  ;