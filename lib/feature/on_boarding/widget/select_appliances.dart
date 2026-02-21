import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SelectAppliances extends StatelessWidget {
  const SelectAppliances({
    super.key,
    required this.title,
    required this.description,
    required this.svgPath,
  });
  final String title;
  final String description;
  final String svgPath;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(svgPath),
                ),
                SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Spacer(),

                Checkbox(
                  value: false,
                  activeColor: Theme.of(context).primaryColor,

                  onChanged: (value) {
                    // Handle checkbox change
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
