import 'package:flutter/material.dart';
import 'package:myportfolio_mobile/models/award.dart';
import 'package:myportfolio_mobile/models/experience.dart';
import 'package:myportfolio_mobile/services/api_client.dart';
import 'package:myportfolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ExperienceListScreen extends StatelessWidget {
  const ExperienceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _PortfolioListScreen<Experience>(
      title: 'Daftar Experience',
      emptyMessage: 'Belum ada experience.',
      load: (api) => api.getExperiences(),
      heading: (item) => item.title,
      subtitle: (item) => item.categoryLabel,
      description: (item) => item.description,
      details: (context, item) {
        final format = MaterialLocalizations.of(context).formatMediumDate;
        final end = item.endedAt;
        return _EntryDetails(
          title: item.title,
          subtitle: item.categoryLabel,
          date:
              '${format(item.startedAt.toLocal())} – '
              '${end == null ? 'Masih berlangsung' : format(end.toLocal())}',
          description: item.description,
        );
      },
    );
  }
}

class AwardListScreen extends StatelessWidget {
  const AwardListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _PortfolioListScreen<Award>(
      title: 'Daftar Award',
      emptyMessage: 'Belum ada award.',
      load: (api) => api.getAwards(),
      heading: (item) => item.title,
      subtitle: (item) => item.recognition,
      description: (item) => item.description,
      details: (context, item) => _EntryDetails(
        title: item.title,
        subtitle: item.recognition,
        date: MaterialLocalizations.of(context)
            .formatMediumDate(item.awardedAt),
        description: item.description,
        image: item.image,
      ),
    );
  }
}

class _PortfolioListScreen<T> extends StatefulWidget {
  const _PortfolioListScreen({
    required this.title,
    required this.emptyMessage,
    required this.load,
    required this.heading,
    required this.subtitle,
    required this.description,
    required this.details,
  });

  final String title;
  final String emptyMessage;
  final Future<List<T>> Function(ApiClient) load;
  final String Function(T) heading;
  final String Function(T) subtitle;
  final String Function(T) description;
  final Widget Function(BuildContext, T) details;

  @override
  State<_PortfolioListScreen<T>> createState() =>
      _PortfolioListScreenState<T>();
}

class _PortfolioListScreenState<T> extends State<_PortfolioListScreen<T>> {
  late Future<List<T>> _entries;

  @override
  void initState() {
    super.initState();
    _entries = widget.load(context.read<ApiClient>());
  }

  Future<void> _reload() async {
    final future = widget.load(context.read<ApiClient>());
    setState(() => _entries = future);
    try {
      await future;
    } catch (_) {
      // FutureBuilder displays the error and offers a retry.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<T>>(
        future: _entries,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Daftar gagal dimuat.'),
                  TextButton(
                    onPressed: _reload,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            );
          }
          final entries = snapshot.requireData;
          return RefreshIndicator(
            onRefresh: _reload,
            child: entries.isEmpty
                ? CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text(widget.emptyMessage)),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final item = entries[index];
                      return Card(
                        child: ListTile(
                          title: Text(widget.heading(item)),
                          subtitle: Text(
                            '${widget.subtitle(item)}\n${widget.description(item)}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          isThreeLine: true,
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push<void>(
                            MaterialPageRoute(
                              builder: (context) =>
                                  widget.details(context, item),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _EntryDetails extends StatelessWidget {
  const _EntryDetails({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.description,
    this.image = '',
  });

  final String title;
  final String subtitle;
  final String date;
  final String description;
  final String image;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (image.isNotEmpty)
              Image.network(
                image,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    const Center(child: Text('Gambar gagal dimuat.')),
              ),
            Text(title, style: textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(subtitle, style: textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(date),
            const SizedBox(height: 16),
            Text(description),
          ],
        ),
      ),
    );
  }
}
