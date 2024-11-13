import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms and Conditions'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              textAlign: TextAlign.justify,
              'Welcome to ELK',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              'These are the Terms and Conditions administering your utilization of the Website ("hereinafter referred to as Acceptable Use Policy "AUP"). By getting to ELK either through the website or some other electronic gadget, you recognize, acknowledge and consent to the accompanying terms of the AUP, which are intended to ensure that ELK works for everybody. This AUP is compelling from the time you sign in to ELK. By tolerating this AUP, you are likewise tolerating and consenting to be limited by the Privacy Policy and the Listing Policy.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              '1. Using ELK',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              'By using ELK, you acknowledge and agree that it is a technology-enabled electronic platform for advertising information about products and services. You also understand that we do not endorse, market, or guarantee any products or services posted or listed on our site. We do not possess or distribute any products or services mentioned on our platform. While interacting with other users regarding any ad listings or information, we strongly encourage you to exercise reasonable diligence as you would in offline transactions. Use judgment and common sense before renting, buying, or hiring any products or services. When using ELK\'s classifieds, discussion forums, comments, feedback, or other services, you agree to post in the appropriate category and adhere to the Acceptable Use Policy (AUP), including the Ad Posting Policy, which prohibits listing restricted items and is detailed below.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              '1A. Prosper ID',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              'Terms of Using and rights of possession during the rental period of Prosper ID.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              '* You are considered as the possessor of that free allotted prosper ID only during its possession period and it will act as your identification on ELK.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              '2. Ad Posting Policy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              'To use our website, app, and other services, you confirm and agree that you will not list, post, or provide information regarding the rental or exchange of products and services, or any content that is illegal under the laws of the Republic of India, as specified in the prohibited items policy below.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              '2A. Prohibited Items Policy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              'Alcoholic Beverages, Liquor, tobacco products, drugs, psychotropic substances, narcotics, intoxicants of any description, medicines, palliative/curative substances nor shall you provide link directly or indirectly to or include descriptions of items, products or services that are prohibited under any applicable law for the time being in force including but not limited to the Drugs and Cosmetics Act, 1940, the Drugs and Magic Remedies (Objectionable Advertisements) Act, 1954 Narcotic Drug and Prohibited Substances Act and the Indian Penal Code, 1860.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              'Dead person and/or the whole or any part of any human which has been kept or preserved by any means whether artificial or natural including any blood, bodily fluids and/ or body parts.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              '2C. In addition to the above and for the purposes of clarity, all Users shall be expected to adhere to and comply with the following Policies while listing items.',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              'Duplicate Ad listings are not allowed. Any ad posted more than once with the same content or Title in the same city and category would be considered as a Duplicate Ad. We advise you to post multiple ads only if you have different items for rent or different services for hire. All duplicate ads would be deleted and posters penalized if the problem persists.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              'Restricted Item Policy: In addition to the above-prohibited items policy users shall also adhere to and comply with the restricted items policy while listing, posting or providing information in relation to any products or services.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              'Mature Audience/Sexually oriented material: Classifieds relating to items that include items intended for use in sexual activity would not be permitted.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              '3. Consequences of Breach of Listing Policy',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              'Users who violate the prohibited items policy and or the restricted items policy may be subject to the following actions:',
            ),
            SizedBox(height: 8),
            BulletList([
              'Permanent blocking of access to the site.',
              'Suspension or termination of Prosper ID/membership.',
              'Reporting to Law Enforcement or Appropriate Authorities.',
            ]),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              '3A. "Your Information" is defined as any information you provide to us or other users of the Site during the registration, posting, listing, or replying process of classifieds, in the feedback area (if any), through the discussion forums or in the course of using any other feature of the Services. You agree that you are the lawful owner having all rights, title, and interest in your information, and further agree that you are solely responsible and accountable for Your Information and that we act as a mere platform for your online distribution and publication of Your Information.',
            ),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              '3B. You agree that your Ad listing, posting, and/or Information:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            BulletList([
              'Shall not be fraudulent, misrepresent, mislead or pertain to the sale of any illegal, counterfeit, stolen products and/or services.',
              'Shall not consist of material that is an expression of bigotry, racism, or hatred based on age, gender, race, religion, caste, class, lifestyle preference, and nationality and/or is in the nature of being derogatory, slanderous to any third party.',
              'Shall not be obscene, contain pornography, or contain “indecent representation of women” within the meaning of the Indecent Representation of Women (Prohibition) Act, 1986.',
              'Shall not pertain to Products or Services of which you are not the lawful owner or you do not have the authority or consent to list.',
              'Shall not infringe any intellectual property, trade secret, or other proprietary right or rights of publicity or privacy of any third party.',
              'Shall not distribute or contain spam, multiple / chain letters, or pyramid schemes in any of its forms.',
              'Shall not distribute viruses or any other technologies that may harm ELK or the interests or property of ELK users or impose an unreasonable load on the infrastructure or interfere with the proper working of ELK.',
              'You consent to receive communications by email, SMS, call, or by such other mode of communication, electronic or otherwise related to the services provided through the website.',
              'Shall not, directly or indirectly, offer, attempt to offer, trade, or attempt to trade in any products and services, the dealing of which is prohibited or restricted in any manner under the provisions of any applicable law, rule, regulation, or guideline for the time being in force.',
              'Shall not list or post or pertain to information that is either prohibited or restricted under the laws of the Republic of India and such listing, posting or information shall not violate ELK\'s Ad Posting Policy.',
            ]),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              'You agree that your Ad listing, posting, and/or Information: If you are registering on the Website/App, you are responsible for maintaining the confidentiality of your User ID, password, email address and for restricting access to your computer, computer system, computer network, and your ELK account, and you are responsible for all activities that occur under your User ID and password. If you access the Site using any electronic device other than by registration on the Site, the AUP remains applicable to you in the same manner as if you are a registered user on the Site.',
            ),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              '4. Value Added Services',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              'ELK offers several value-added services for users who want to promote their products or services to gain special attention from viewers and receive more business inquiries. These services are optional, and ELK never pressures any user to utilize them at any time.',
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              'ELK reserves the complete rights to edit, modify, remove or introduce new value-added services in the future.',
            ),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              '4A. Prosper ID',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            BulletList([
              'On successful login, System will allot an Alpha Numeric ID (e.g. AB1234) which will be issued to you without rental cost.',
              'You are considered as the possessor of that free allotted prosper ID only during its possession period and it will act as your identification on ELK.',
              'Entering the Prosper ID on URL or on the Search tab on Android/iOS app will display only the Ads pertaining to that corresponding Prosper ID.',
            ]),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              '4B. Banner Promotions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            BulletList([
              'Individual or Business entities indulging in Rental Products or Freelancing Services can promote their business by obtaining the Banner space by paying the fixed cost.',
              'Banners can be created for future dates only that is from the next day onwards to a maximum of 30 days.',
              'Banners will be visible to all users logging in to the Application/Website from the respective cities for which the Banner was hoisted by the advertiser.',
              'Individual Users or Business entities having a minimum of one valid live ad can only create Banner advertisements.',
              'Individuals or Companies can only Promote the Business and relevant details on Banners and ELK holds the authority to edit, modify and remove the content as per the Ad posting policy in section 2.',
              'The cost of the Banner will be different for each city and ELK holds the full rights over the rental fee of the Banner for respective cities.',
              'ELK holds the authority to publish or reject any banners based on the guidelines mentioned in sections 2 and 2A.',
              'Company Logo or Products image of the respective advertiser will only be published, photos of any person will not be allowed on the Banner.',
              'Banner posted for the particular day will be auto hoisted by the system and the user has rights to edit the content as well as to deactivate the Banner by his will. The rental fee paid for the Banner is not entitled to be refunded on this occasion.',
              'A banner hoisted for any day will be displayed on the ELK front end from 12 AM to 11.59 PM of the appropriate day.',
              'ELK holds the right to reject the Banner which is not complying with the Banner posting protocols as per the ELK admin team and the fee paid by the user will be refunded in this scenario.',
              'ELK never guarantees the surge of Business inquiries to the party who availed Banner space since business inquiries to the particular product or service is depending upon the market demands of the appropriate cities.',
            ]),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              '4C. Boost Ads',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            BulletList([
              'There are two options in the Boost Ads segment: 1. Top of the Page. 2. Premium Ads.',
              'Any Active ads could be Boosted by the user to the Top of the Page or Premium according to their choices.',
              'Individual Users or Business entities having a minimum of one valid live ad can avail of this value-added service.',
              'The top of the Page option can be only availed for 2, 4 and 6 days maximum whereas the Premium option can be chosen for 3, 5 and 7 days only. ELK reserves the right to edit, modify and change the pattern that includes charges, no of days, and everything pertaining to this module.',
              'Any existing ads can be boosted to Top of the Page or Premium and the same will be effective in real-time. The user has the option to boost the Ad from the current date. The charges paid for the Boost Ad are not entitled to be refunded on any occasion.',
              'The cost of the Top of the Page and Premium options will be different for each city and ELK holds full rights over the charges of the value-added services.',
              'The "top of the page" boosted ad will be pinned on top of the page in the appropriate Product or Service category for the selected dates and will be visible to all users logging in to the Application/Website from the respective cities of the base city of the particular ad.',
              'The Premium Ads will be listed in a separate segment as premium ads at the end of the category and will be visible to all users logging in to the Application/Website from the respective cities of the base city of the particular ad.',
              'ELK never guarantees the surge of Business inquiries to the party who availed the Boost Ads option since business inquiries to the particular product or service depend upon the market demands of the appropriate cities.',
            ]),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              '14. Governing Law & Jurisdiction',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              'This AUP and the Listing Policy shall be governed and construed in accordance with the laws of the Republic of India shall have exclusive jurisdiction on all matters and disputes arising out of and relating to the Site.',
            ),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              '15. No Guarantee of Business',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              'ELK does not guarantee business from the leads generated. ELK shall not be responsible or liable at all to the Advertiser if no business or business leads are generated for the Advertiser through Top of the Page/ Premium ads on the Website/app. Advertiser understands that ELK’s only obligation is to place the Top of the Page/Premium Ads on the Website in the manner provided for in these Terms. Accuracy of the information/content provided is the advertiser\'s responsibility and ELK will not be held responsible for false claims made by the advertiser.',
            ),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              '16. Advertiser Obligations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              'Advertiser represents and warrants that (i) it is a bonafide business organization or individual carrying on business in relation to the items disclosed to ELK, (ii) it has the right to use the trademarks it claims to have the right to use (iii) the business carried on by Advertiser does not violate or infringe upon any law or regulation and all registrations required for carrying on business have been procured by it and (iv) all Classified(s) provided to ELK is/are and shall at all times be accurate and complete, and entirely lawful. The Advertiser shall bear complete responsibility for the quality of its products and/or services, and ELK shall bear no responsibility for the same. The Advertiser agrees to be bound by all applicable policies of ELK relating to Classifieds and the Website, and the Advertiser grants to ELK a worldwide intellectual property license (including a copyright and trademark license) relating to all intellectual property rights in the Classified(s) to do any acts in relation to the Classified(s) which ELK may deem necessary to fulfill its obligations.',
            ),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              '17. Notice of Infringement of Intellectual Property',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              'ELK is not liable for any infringement of intellectual property rights arising out of Products & Services posted on the site by end-users or any other third parties. If you are an owner of intellectual property rights or an agent who is fully authorized to act on behalf of the owner of intellectual property rights and believe that any Content or other content infringes upon your intellectual property right or intellectual property right of the owner on whose behalf you are authorized to act, you may write to us at support@ELK.in to delete the relevant Content in good faith.',
            ),
            SizedBox(height: 16),
            Text(
              textAlign: TextAlign.justify,
              '18. Cautions & Disclaimers',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              'We strongly recommend our users exercise their discretion & due diligence about all relevant aspects prior to availing of any products/services. Please note that ELK does not implicitly or explicitly endorse any product/s or services provided by advertisers/service providers. Service providers at all times ensure that all the applicable laws that govern their profession are followed while rendering their services.',
            ),
            Text(
              textAlign: TextAlign.justify,
              'We strongly advise the users to upload the images of their original product and their own images while posting Ads of Rental Products and Freelancing Services respectively. However, ELK shall not be responsible for third-party images downloaded or used by the users while posting their Ads. ELK also reserves the right to edit/update/correct/delete/add watermarks on any images uploaded by the users.',
            ),
            Text(
              textAlign: TextAlign.justify,
              'The information related to the name, address, contact details of the business establishments has been verified as existing at the time of verification of any advertiser with ELK. This verification is solely based on the documents as supplied by an advertiser/s or as per the details contained in the User verification page.',
            ),
            Text(
              textAlign: TextAlign.justify,
              'We strongly recommend our users exercise their discretion & due diligence about all relevant aspects before availing of any products/services. Please note that ELK does not implicitly or explicitly endorse any product/s or services provided by advertisers/service providers.',
            ),
            Text(
              textAlign: TextAlign.justify,
              'ELK is not responsible for any disputes arising due Fraudulent activities/Deceptive/Misleading Misbehaving/Cheating by the other User and ELK is nowhere responsible for any of these consequences however User can escalate to support@ELK.in to complain about the particular Post/User and ELK reserves the sole authority to take action in favor of same.',
            ),
            SizedBox(height: 16),
            Text(
              '19. Miscellaneous',
              textAlign: TextAlign.justify,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              textAlign: TextAlign.justify,
              'If all premium ads available to the advertiser under the subscription scheme are not used/availed of during the period of these terms, the unutilized units shall be forfeited - no refund shall be made, and neither can the unutilized credits be carried forward.',
            ),
            Text(
              textAlign: TextAlign.justify,
              'The banner shall be dynamically created by Users from their dashboard. Banner hoisting is a paid service and the banners will be displayed on a rotational basis. ELK reserves the right to approve/Reject the banner and ELK retains the rights of allotting “N no of banners on the particular time slot on user preferred destination cities. ELK does not provide any guarantees of impressions or clicks on the banners.',
            ),
            Text(
              textAlign: TextAlign.justify,
              'Premium ads are prioritized over free ads on the website on the search and browse pages. The sequence in which premium ads are displayed will be controlled by ELK\'s search algorithm which is ELK\'s sole prerogative. The advertiser shall not have a say in determining the sequence in which ads are displayed within the set of premium ads matching a user\'s search query/browsing intent.',
            ),
            Text(
              textAlign: TextAlign.justify,
              'The advertiser acknowledges that any liability/claim in respect of the products or services promoted through the Banners/Advertisements under the scope of this Agreement shall be solely to the account of the advertiser. It is agreed that in case of any claims in respect of the same against ELK, the advertiser shall indemnify ELK against all such claims and damages.',
            ),
            Text(
              textAlign: TextAlign.justify,
              'Advertiser shall procure and keep valid all necessary licenses, permissions, authorizations, consents, approvals, and registrations with/from any government department, agency, or authority required for it to perform the Services in accordance with this Agreement and bear sole and exclusive responsibility for all compliances with such licenses, permissions, authorizations, consents, approvals, and registrations.',
            ),
          ],
        ),
      ),
    );
  }
}

class BulletList extends StatelessWidget {
  final List<String> items;

  const BulletList(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Row(
                children: [
                  const Icon(Icons.brightness_1, size: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        item,
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                ],
              ))
          .toList(),
    );
  }
}
