jQuery(document).ready(function () {
    jQuery('form input[name="phone"]').on("click keyup change blur input paste", function () {
        let _this = jQuery(this),
            value = _this.val();
        //только цифры и знак +
        _this.val(value.replace(/[^\d\+]/g, ''))

        //только цифры и знак + и знак скобок
        //_this.val(value.replace(/[^\d\(\)\+]/g, ''))

        //только цифры и знак + и знак скобок и пробел
        //_this.val(value.replace(/[^\d\(\)\+ ]/g, ''))

        //только цифры и знак + и знак скобок и пробел и -
        //_this.val(value.replace(/[^\d\(\)\-\+ ]/g, ''))
    });

    jQuery('form input[name="uname"], form input[name="your-name"], form input[name="name"]').on("click keyup change blur input paste", function () {
        let _this = jQuery(this),
            value = _this.val();
        //только кириллица и латиница и пробел и знак -
        _this.val(value.replace(/[^a-zA-Zа-яёА-ЯЁ -]/u, ''))
    });

});