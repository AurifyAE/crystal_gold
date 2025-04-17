import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/bank_model.dart';

class IOSBankCard extends StatelessWidget {
  final BankDetails bankDetails;
  
  const IOSBankCard({Key? key, required this.bankDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CupertinoListSection.insetGrouped(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        margin: EdgeInsets.zero,
        header: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://api.aurify.ae${bankDetails.logo}',
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 40,
                    width: 40,
                    color: CupertinoColors.systemGrey5,
                    child: const Icon(CupertinoIcons.building_2_fill, color: CupertinoColors.systemGrey),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bankDetails.bankName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Account Holder: ${bankDetails.holderName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          _buildDetailRow('Account Number', bankDetails.accountNumber, true, context),
          _buildDetailRow('IBAN', bankDetails.iban, false, context),
          _buildDetailRow('IFSC Code', bankDetails.ifsc, false, context),
          _buildDetailRow('SWIFT Code', bankDetails.swift, false, context),
          _buildDetailRow('Branch', bankDetails.branch, false, context),
          _buildDetailRow('City', bankDetails.city, false, context),
          _buildDetailRow('Country', bankDetails.country, false, context),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, bool canCopy, BuildContext context) {
    return CupertinoListTile(
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          color: CupertinoColors.secondaryLabel,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: CupertinoColors.label,
            ),
          ),
          if(canCopy)
          SizedBox(width: 20,),
          if (canCopy)
            CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => CupertinoActionSheet(
                    title: const Text('Copied to Clipboard'),
                    message: Text('$label has been copied to clipboard.'),
                    actions: [
                      CupertinoActionSheetAction(
                        isDefaultAction: true,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              },
              child: const Icon(
                CupertinoIcons.doc_on_doc,
                size: 18,
                color: CupertinoColors.activeBlue,
              ),
            ),
        ],
      ),
    );
  }
}