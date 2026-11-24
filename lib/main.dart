
import 'package:flutter/material.dart';

void main() {
  runApp(const ClinicaVeterinaria());
}

// MODELO DO PACIENTE
class Paciente {
  String paciente;
  String raca;
  String responsavel;

  Paciente({
    required this.paciente,
    required this.raca,
    required this.responsavel,
  });
}

// APLICACAO PRINCIPAL
class ClinicaVeterinaria extends StatelessWidget {
  const ClinicaVeterinaria({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Clínica Veterinária',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
      ),
      home: const TelaInicial(),
    );
  }
}

// TELA DE LISTAGEM
class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {

  // LISTA EM MEMORIA
  final List<Paciente> pacientes = [
    Paciente(
      paciente: 'Luna',
      raca: 'Poodle',
      responsavel: 'Bruno',
    ),
  ];

  // CADASTRAR PACIENTE
  void cadastrarPaciente() async {
    final resultado = await Navigator.push<Paciente>(
      context,
      MaterialPageRoute(
        builder: (context) => const TelaFormulario(),
      ),
    );

    if (resultado != null) {
      setState(() {
        pacientes.add(resultado);
      });
    }
  }

  // EDITAR PACIENTE
  void editarPaciente(int index) async {
    final resultado = await Navigator.push<Paciente>(
      context,
      MaterialPageRoute(
        builder: (context) => TelaFormulario(
          paciente: pacientes[index],
        ),
      ),
    );

    if (resultado != null) {
      setState(() {
        pacientes[index] = resultado;
      });
    }
  }

  // EXCLUIR PACIENTE
  void excluirPaciente(int index) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir paciente'),
        content: Text(
          'Deseja excluir ${pacientes[index].paciente}?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      setState(() {
        pacientes.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Clínica Veterinária',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),

      body: pacientes.isEmpty
          ? const Center(
        child: Text(
          'Nenhum paciente cadastrado.',
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pacientes.length,
        itemBuilder: (context, index) {
          final paciente = pacientes[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.pets),
              ),

              title: Text(
                paciente.paciente,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Text(
                'Raça: ${paciente.raca}\n'
                    'Responsável: ${paciente.responsavel}',
              ),

              isThreeLine: true,

              trailing: PopupMenuButton<String>(
                onSelected: (opcao) {
                  if (opcao == 'editar') {
                    editarPaciente(index);
                  } else if (opcao == 'excluir') {
                    excluirPaciente(index);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'editar',
                    child: Text('Editar'),
                  ),
                  const PopupMenuItem(
                    value: 'excluir',
                    child: Text('Excluir'),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: cadastrarPaciente,
        icon: const Icon(Icons.add),
        label: const Text('Novo paciente'),
      ),
    );
  }
}

// TELA DE CADASTRO E EDICAO
class TelaFormulario extends StatefulWidget {
  final Paciente? paciente;

  const TelaFormulario({
    super.key,
    this.paciente,
  });

  @override
  State<TelaFormulario> createState() => _TelaFormularioState();
}

class _TelaFormularioState extends State<TelaFormulario> {

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController pacienteController;
  late final TextEditingController racaController;
  late final TextEditingController responsavelController;

  @override
  void initState() {
    super.initState();

    pacienteController = TextEditingController(
      text: widget.paciente?.paciente ?? '',
    );

    racaController = TextEditingController(
      text: widget.paciente?.raca ?? '',
    );

    responsavelController = TextEditingController(
      text: widget.paciente?.responsavel ?? '',
    );
  }

  @override
  void dispose() {
    pacienteController.dispose();
    racaController.dispose();
    responsavelController.dispose();
    super.dispose();
  }

  // VALIDAR E SALVAR
  void salvarPaciente() {
    if (_formKey.currentState!.validate()) {
      final novoPaciente = Paciente(
        paciente: pacienteController.text.trim(),
        raca: racaController.text.trim(),
        responsavel: responsavelController.text.trim(),
      );

      Navigator.pop(context, novoPaciente);
    }
  }

  // VALIDACAO DOS CAMPOS
  String? validarCampo(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return 'Este campo é obrigatório.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.paciente != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          editando ? 'Editar paciente' : 'Novo paciente',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              const Icon(
                Icons.pets,
                size: 70,
                color: Colors.teal,
              ),

              const SizedBox(height: 24),

              const Text(
                'Dados do paciente',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: pacienteController,
                decoration: const InputDecoration(
                  labelText: 'Paciente',
                  hintText: 'Nome do animal',
                  prefixIcon: Icon(Icons.pets),
                  border: OutlineInputBorder(),
                ),
                validator: validarCampo,
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: racaController,
                decoration: const InputDecoration(
                  labelText: 'Raça',
                  hintText: 'Raça do animal',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                validator: validarCampo,
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: responsavelController,
                decoration: const InputDecoration(
                  labelText: 'Responsável',
                  hintText: 'Nome do responsável',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: validarCampo,
              ),

              const SizedBox(height: 28),

              FilledButton.icon(
                onPressed: salvarPaciente,
                icon: const Icon(Icons.save),
                label: Text(
                  editando ? 'Salvar alterações' : 'Cadastrar paciente',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
