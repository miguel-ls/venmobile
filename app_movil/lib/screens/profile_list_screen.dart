import 'dart:convert';
import 'package:app_movil/config/api_config.dart';
import 'package:app_movil/models/profile.dart';
import 'package:app_movil/screens/profile_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProfileListScreen extends StatefulWidget {
  const ProfileListScreen({super.key});

  @override
  _ProfileListScreenState createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  late Future<List<Profile>> _profilesFuture;

  @override
  void initState() {
    super.initState();
    _profilesFuture = _fetchProfiles();
  }

  Future<List<Profile>> _fetchProfiles() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/profiles'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((profile) => Profile.fromJson(profile)).toList();
    } else {
      throw Exception('Failed to load profiles');
    }
  }

  Future<void> _deleteProfile(int id) async {
    final response = await http.delete(Uri.parse('${ApiConfig.baseUrl}/profiles/$id'));

    if (response.statusCode == 200) {
      setState(() {
        _profilesFuture = _fetchProfiles();
      });
    } else {
      throw Exception('Failed to delete profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfiles'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileEditScreen()),
              );
              setState(() {
                _profilesFuture = _fetchProfiles();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Profile>>(
        future: _profilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay perfiles'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final profile = snapshot.data![index];
                return ListTile(
                  title: Text(profile.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProfileEditScreen(profile: profile)),
                          );
                          setState(() {
                            _profilesFuture = _fetchProfiles();
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteProfile(profile.id),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
