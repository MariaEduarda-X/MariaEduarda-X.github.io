class Planeta {
  int id;
  String nome;
  String apelido;
  double distanciaDoSol;
  double tamanho;

  Planeta({
    this.id,
    required this.nome,
    this.apelido,
    required this.distanciaDoSol,
    required this.tamanho,
  });

  factory Planeta.fromMap(Map<String, dynamic> map) {
    return Planeta(
      id: map['id'],
      nome: map['nome'],
      apelido: map['apelido'],
      distanciaDoSol: map['distanciaDoSol'],
      tamanho: map['tamanho'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'apelido': apelido,
      'distanciaDoSol': distanciaDoSol,
      'tamanho': tamanho,
    };
  }
}




import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'planeta.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await createDatabase();
    return _database!;
  }

  Future<Database> createDatabase() async {
    String path = join(await getDatabasesPath(), 'planetas.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute('''
        CREATE TABLE planetas (
          id INTEGER PRIMARY KEY,
          nome TEXT NOT NULL,
          apelido TEXT,
          distanciaDoSol REAL NOT NULL,
          tamanho REAL NOT NULL
        )
      ''');
    });
  }

  Future<int> insertPlaneta(Planeta planeta) async {
    final db = await database;
    return await db.insert('planetas', planeta.toMap());
  }

  Future<List<Planeta>> getAllPlanetas() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('planetas');
    return List.generate(maps.length, (i) {
      return Planeta.fromMap(maps[i]);
    });
  }

  Future<int> updatePlaneta(Planeta planeta) async {
    final db = await database;
    return await db.update('planetas', planeta.toMap(),
        where: 'id = ?', whereArgs: [planeta.id]);
  }

  Future<int> deletePlaneta(int id) async {
    final db = await database;
    return await db.delete('planetas', where: 'id = ?', whereArgs: [id]);
  }
}





import 'package:flutter/material.dart';
import 'package:planetas_app/database.dart';
import 'package:planetas_app/planeta.dart';
import 'package:planetas_app/add_planeta_page.dart';
import 'package:planetas_app/detalhes_planeta_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Planeta> _planetas = [];
  DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _getAllPlanetas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planetas'),
      ),
      body: ListView.builder(
        itemCount: _planetas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_planetas[index].nome),
            subtitle: Text(_planetas[index].apelido),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalhesPlanetaPage(
                    planeta: _planetas[index],
                  ),
                ),
              );
