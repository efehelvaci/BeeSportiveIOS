//
//  PrivacyPolicy.swift
//  BeeSportive
//
//  Created by Efe Helvaci on 8.10.2016.
//  Copyright © 2016 BeeSportive. All rights reserved.
//

import Foundation

func getPrivacyPolicy () -> NSMutableAttributedString {
    let regularFontAttribute = [NSFontAttributeName: UIFont.systemFont(ofSize: 15)]
    let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)]
    
    let privacyPolicy = "This privacy policy has been compiled to better serve those who are concerned with how their 'Personally Identifiable Information' (PII) is being used online. PII, as described in information security, is information that can be used on its own or with other information to identify, contact, or locate a single person, or to identify an individual in context. Please read our privacy policy carefully to get a clear understanding of how we collect, use, protect or otherwise handle your Personally Identifiable Information in accordance with our IOS application." + "\n" + "\n" +
        
        "What personal information do we collect from the people that visit our blog, website or app?" + "\n" + "\n" +
        
        "When ordering or registering on our app, as appropriate, you may be asked to enter your name, email address or other details to help you with your experience." + "\n" + "\n" +
        
        "When do we collect information?" + "\n" + "\n" +
        
        "We collect information from you when you register on our app or enter information on our app." + "\n" + "\n" +
        
        "How do we use your information?" + "\n" + "\n" +
        
        "We may use the information we collect from you when you register, make a purchase, sign up for our newsletter, respond to a survey or marketing communication, surf the app, or use certain other site features in the following ways" + "\n" + "\n" +
        "• To personalize your experience and to allow us to deliver the type of content and product offerings in which you are most interested." + "\n" +
        "• To allow us to better service you in responding to your customer service requests." + "\n" + "\n" +
        
        "How do we protect your information?" + "\n" + "\n" +
        
        "We do not use vulnerability scanning and/or scanning to PCI standards." + "\n" +
        "We only provide articles and information. We never ask for credit card numbers." + "\n" +
        "We use regular Malware Scanning." + "\n" + "\n" +
        
        "Your personal information is contained behind secured networks and is only accessible by a limited number of persons who have special access rights to such systems, and are required to keep the information confidential. In addition, all sensitive/credit information you supply is encrypted via Secure Socket Layer (SSL) technology." + "\n" + "\n" +
        
        "We implement a variety of security measures when a user enters, submits, or accesses their information to maintain the safety of your personal information." + "\n" + "\n" +
        
        "All transactions are processed through a gateway provider and are not stored or processed on our servers." + "\n" + "\n" +
        
        "Do we use 'cookies'?" + "\n" + "\n" +
        
        "Yes. Cookies are small files that a app or its service provider transfers to your mobile phone's hard drive through your Web browser (if you allow) that enables the site's or service provider's systems to recognize your browser and capture and remember certain information. For instance, we use cookies to help us remember and process the items. They are also used to help us understand your preferences based on previous or current app activity, which enables us to provide you with improved services. We also use cookies to help us compile aggregate data about app traffic and app interaction so that we can offer better app experiences and tools in the future." + "\n" + "\n" +
        
        "We use cookies to:" + "\n" +
        "• Understand and save user's preferences for future visits." + "\n" + "\n" +
        
        "You can choose to have your mobile phone warn you each time a cookie is being sent, or you can choose to turn off all cookies. You do this through your browser settings. Since browser is a little different, look at your browser's Help Menu to learn the correct way to modify your cookies." + "\n" + "\n" +
        
        "If you turn cookies off, some features will be disabled. It won't affect the user's experience that make your app experience more efficient and may not function properly." + "\n" + "\n" +
        
        "Third-party disclosure" + "\n" + "\n" +
        
        "We do not sell, trade, or otherwise transfer to outside parties your Personally Identifiable Information unless we provide users with advance notice. This does not include website hosting partners and other parties who assist us in operating our app, conducting our business, or serving our users, so long as those parties agree to keep this information confidential. We may also release information when it's release is appropriate to comply with the law, enforce our app policies, or protect ours or others' rights, property or safety. However, non-personally identifiable visitor information may be provided to other parties for marketing, advertising, or other uses." + "\n" + "\n" +
        
        "Third-party links" + "\n" + "\n" +
        
        "Occasionally, at our discretion, we may include or offer third-party products or services on our app. These third-party sites have separate and independent privacy policies. We therefore have no responsibility or liability for the content and activities of these linked sites. Nonetheless, we seek to protect the integrity of our app and welcome any feedback about these sites." + "\n" + "\n" +
        
        "Google" + "\n" + "\n" +
        
        "Google's advertising requirements can be summed up by Google's Advertising Principles. They are put in place to provide a positive experience for users. https://support.google.com/adwordspolicy/answer/1316548?hl=en" + "\n" + "\n" +
        
        "We use Google Analytics on our app. Google, as a third-party vendor, uses cookies to serve ads on our app. Google's use of the DART cookie enables it to serve ads to our users based on previous visits to our app and other apps on the Internet. Users may opt-out of the use of the DART cookie by visiting the Google Ad and Content Network privacy policy." + "\n" + "\n" +
        
        "We have implemented the following:" + "\n" +
        "• Demographics and Interests Reporting" + "\n" + "\n" +
        
        "We, along with third-party vendors such as Google use first-party cookies (such as the Google Analytics cookies) and third-party cookies (such as the DoubleClick cookie) or other third-party identifiers together to compile data regarding user interactions with ad impressions and other ad service functions as they relate to our app." + "\n" + "\n" +
        
        "Opting out:" + "\n" +
        "Users can set preferences for how Google advertises to you using the Google Ad Settings page. Alternatively, you can opt out by visiting the Network Advertising Initiative Opt Out page or by using the Google Analytics Opt Out Browser add on." + "\n" + "\n" +
        
        "We agree to the following:" + "\n" +
        "Users can visit our app anonymously. Once this privacy policy is created, we will add a link to it on our home page or as a minimum, on the first significant page after entering our app. Our Privacy Policy link includes the word 'Privacy' and can easily be found on the page specified above." + "\n" + "\n" +
        
        "You will be notified of any Privacy Policy changes:" + "\n" +
        "• On our Privacy Policy Page" + "\n" + "\n" +
        
        "Can change your personal information:" + "\n" +
        "• By logging in to your account" + "\n" + "\n" +
        
        "How does our app handle Do Not Track signals?" + "\n" +
        "We honor Do Not Track signals and Do Not Track, plant cookies, or use advertising when a Do Not Track (DNT) browser mechanism is in place." + "\n" + "\n" +
        
        "Does our app allow third-party behavioral tracking?" + "\n" +
        "It's also important to note that we do not allow third-party behavioral tracking" + "\n" + "\n" +
        
        "Children Online Privacy Protection" + "\n" + "\n" +
        
        "When it comes to the collection of personal information from children under the age of 13 years old, the Children's Online Privacy Protection puts parents in control. We do not specifically market to children under the age of 13 years old." +
        "Fair Information Practices" + "\n" + "\n" +
        
        "The Fair Information Practices Principles form the backbone of privacy law in the United States and the concepts they include have played a significant role in the development of data protection laws around the globe. Understanding the Fair Information Practice Principles and how they should be implemented is critical to comply with the various privacy laws that protect personal information." + "\n" + "\n" +
        
        "In order to be in line with Fair Information Practices we will take the following responsive action, should a data breach occur:" + "\n" +
        "We will notify you via email" + "\n" +
        "• Within 7 business days" + "\n" + "\n" +
        
        "We also agree to the Individual Redress Principle which requires that individuals have the right to legally pursue enforceable rights against data collectors and processors who fail to adhere to the law. This principle requires not only that individuals have enforceable rights against data users, but also that individuals have recourse to courts or government agencies to investigate and/or prosecute non-compliance by data processors." + "\n" + "\n" + "\n" +
        
        
        "About SPAM" + "\n" + "\n" +
        
        "We collect your email address in order to:" + "\n" +
        "• Send information, respond to inquiries, and/or other requests or questions" + "\n" + "\n" +
        
        "We agree to the following:" + "\n" +
        "• Not use false or misleading subjects or email addresses." + "\n" +
        "• Identify the message as an advertisement in some reasonable way." + "\n" +
        "• Include the physical address of our business or app headquarters." + "\n" +
        "• Monitor third-party email marketing services for compliance, if one is used." + "\n" +
        "• Honor opt-out/unsubscribe requests quickly." + "\n" +
        "• Allow users to unsubscribe by using the link at the bottom of each email." + "\n" +
        
        "If at any time you would like to unsubscribe from receiving future emails, you can email us at" + "\n" +
        "• Follow the instructions at the bottom of each email and we will promptly remove you from ALL correspondence." + "\n" +
        
        "Contacting Us" + "\n" + "\n" +
        
        "If there are any questions regarding this privacy policy, you may contact us using the information below." + "\n" + "\n" +
        
        "www.beesportive.com" + "\n" +
        "Istanbul," + "\n" +
        "Turkey" + "\n" +
        "kerem@beesportive.com" + "\n" + "\n" +
        
        "Last Edited on 2016-10-01"
    
    let attributedPrivacyPolicy = NSMutableAttributedString(string: privacyPolicy, attributes: regularFontAttribute)
    
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "What personal information do we collect from the people that visit our blog, website or app?"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "When do we collect information?"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "How do we use your information?"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "How do we protect your information?"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "Do we use 'cookies'?"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "We use cookies to:"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "Third-party disclosure"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "Third-party links"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "Google"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "We have implemented the following:"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "Opting out:"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "We agree to the following:"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "You will be notified of any Privacy Policy changes:"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "Can change your personal information:"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "How does our app handle Do Not Track signals?"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "Does our app allow third-party behavioral tracking?"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "Children Online Privacy Protection"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "Fair Information Practices"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "About SPAM"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "If at any time you would like to unsubscribe from receiving future emails, you can email us at"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "Contacting Us"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "www.beesportive.com"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "Istanbul,"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "Turkey"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "kerem@beesportive.com"))
    attributedPrivacyPolicy.addAttributes(boldFontAttribute, range: NSString(string: privacyPolicy).range(of: "Last Edited on 2016-10-01"))

    return attributedPrivacyPolicy
}



