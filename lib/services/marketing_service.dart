import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketingService {
  final _supabase = Supabase.instance.client;

  /// Fetches the latest active campaign to show as a popup.
  /// Returns null if:
  ///   - No active campaign exists
  ///   - The user has already seen this campaign (stored locally)
  Future<Map<String, dynamic>?> fetchUnseenCampaign() async {
    try {
      final response = await _supabase
          .from('marketing_campaigns')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      final campaignId = response['id'].toString();
      final prefs = await SharedPreferences.getInstance();
      final seenIds = prefs.getStringList('seen_campaign_ids') ?? [];

      if (seenIds.contains(campaignId)) return null;

      // Mark as seen
      seenIds.add(campaignId);
      await prefs.setStringList('seen_campaign_ids', seenIds);

      return response;
    } catch (e) {
      debugPrint('Marketing popup error: $e');
      return null;
    }
  }
}
